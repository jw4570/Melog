//
//  PitchDetectionService.swift
//  Melog
//
//  Created by Aside on 8/30/26.
//

import AVFoundation
import Foundation
import Observation

@Observable
@MainActor
final class PitchDetectionService {
    private let audioEngine = AVAudioEngine()
    private var hasInputTap = false
    private var recentMIDINotes: [Double] = []
    private var smoothedMIDINote: Double?
    private var stableMIDINote: Int?
    private var missingPitchCount = 0

    private(set) var currentPitch: DetectedPitch?
    private(set) var processedPitch: DetectedPitch?

    func start() throws {
        stop()

        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)

        guard format.sampleRate > 0,
              format.channelCount > 0 else {
            throw RecordingError.failedToStart
        }

        var lastAnalysisTime: TimeInterval = 0
        let analysisGate = DispatchSemaphore(value: 1)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 4_096,
            format: format
        ) { [weak self] buffer, _ in
            let now = ProcessInfo.processInfo.systemUptime
            guard now - lastAnalysisTime >= 0.08 else {
                return
            }
            lastAnalysisTime = now

            guard analysisGate.wait(
                timeout: .now()
            ) == .success else {
                return
            }

            guard let channelData = buffer.floatChannelData?[0] else {
                analysisGate.signal()
                return
            }

            let frameCount = Int(buffer.frameLength)
            let samples = Array(
                UnsafeBufferPointer(
                    start: channelData,
                    count: frameCount
                )
            )
            let sampleRate = format.sampleRate

            Task.detached(priority: .userInitiated) {
                defer { analysisGate.signal() }

                let pitch = Self.detectPitch(
                    samples: samples,
                    sampleRate: sampleRate
                )

                await MainActor.run {
                    guard self?.audioEngine.isRunning == true else {
                        return
                    }
                    self?.updateProcessedPitch(
                        from: pitch
                    )
                }
            }
        }

        hasInputTap = true
        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            stop()
            throw error
        }
    }

    func stop() {
        if hasInputTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasInputTap = false
        }

        audioEngine.stop()
        audioEngine.reset()
        currentPitch = nil
        processedPitch = nil
        recentMIDINotes = []
        smoothedMIDINote = nil
        stableMIDINote = nil
        missingPitchCount = 0
    }

    private func updateProcessedPitch(
        from rawPitch: DetectedPitch?
    ) {
        currentPitch = rawPitch

        guard let rawPitch else {
            missingPitchCount += 1

            if missingPitchCount >= 4 {
                processedPitch = nil
                recentMIDINotes.removeAll()
            }
            return
        }

        missingPitchCount = 0

        let exactMIDINote = Double(rawPitch.midiNote)
            + rawPitch.cents / 100

        // 5개 샘플의 중앙값을 사용해 한두 프레임만 발생하는
        // 배음 기반 옥타브 오검출과 순간적인 튐을 제거합니다.
        recentMIDINotes.append(exactMIDINote)
        if recentMIDINotes.count > 5 {
            recentMIDINotes.removeFirst()
        }

        let sortedNotes = recentMIDINotes.sorted()
        let medianNote = sortedNotes[sortedNotes.count / 2]

        let smoothedNote: Double
        if let previous = smoothedMIDINote {
            let difference = abs(medianNote - previous)
            let smoothingFactor = difference > 2 ? 0.55 : 0.28
            smoothedNote = previous
                + (medianNote - previous) * smoothingFactor
        } else {
            smoothedNote = medianNote
        }
        smoothedMIDINote = smoothedNote

        // 경계 근처의 떨림 때문에 C와 C♯이 반복되지 않도록
        // 현재 음의 중심에서 65 cent 이상 벗어날 때만 변경합니다.
        if let stableMIDINote {
            if abs(smoothedNote - Double(stableMIDINote)) >= 0.65 {
                self.stableMIDINote = Int(smoothedNote.rounded())
            }
        } else {
            stableMIDINote = Int(smoothedNote.rounded())
        }

        guard let stableMIDINote else { return }

        let frequency = 440
            * pow(2, (smoothedNote - 69) / 12)
        let cents = (smoothedNote - Double(stableMIDINote)) * 100

        processedPitch = DetectedPitch(
            midiNote: stableMIDINote,
            frequency: frequency,
            cents: cents
        )
    }

    nonisolated private static func detectPitch(
        samples: [Float],
        sampleRate: Double
    ) -> DetectedPitch? {
        guard samples.count >= 2_048 else { return nil }

        let analysisCount = min(samples.count, 2_048)
        let analysisSamples = Array(samples.prefix(analysisCount))

        let meanSquare = analysisSamples.reduce(0.0) {
            $0 + Double($1 * $1)
        } / Double(analysisCount)
        let rootMeanSquare = sqrt(meanSquare)

        // 약 -52 dB 이하만 무음으로 처리합니다.
        // 작은 허밍도 분석하되, 아래 자기상관 신뢰도 검사로
        // 주변 소음이 음으로 판정되는 것을 제한합니다.
        guard rootMeanSquare > 0.0025 else { return nil }

        let minimumFrequency = 65.0
        let maximumFrequency = 1_050.0
        let minimumLag = max(
            2,
            Int(sampleRate / maximumFrequency)
        )
        let maximumLag = min(
            analysisCount / 2,
            Int(sampleRate / minimumFrequency)
        )

        var bestLag = 0
        var bestCorrelation = 0.0
        var correlations = Array(
            repeating: 0.0,
            count: maximumLag + 1
        )

        for lag in minimumLag...maximumLag {
            var correlation = 0.0
            var energyA = 0.0
            var energyB = 0.0
            var index = 0

            while index + lag < analysisCount {
                let sampleA = Double(analysisSamples[index])
                let sampleB = Double(
                    analysisSamples[index + lag]
                )

                correlation += sampleA * sampleB
                energyA += sampleA * sampleA
                energyB += sampleB * sampleB
                index += 2
            }

            let denominator = sqrt(energyA * energyB)
            guard denominator > 0 else { continue }

            let normalizedCorrelation =
                correlation / denominator
            correlations[lag] = normalizedCorrelation

            if normalizedCorrelation > bestCorrelation {
                bestCorrelation = normalizedCorrelation
                bestLag = lag
            }
        }

        guard bestLag > 0,
              bestCorrelation > 0.6 else {
            return nil
        }

        var refinedLag = Double(bestLag)

        if bestLag > minimumLag,
           bestLag < maximumLag {
            let previous = correlations[bestLag - 1]
            let current = correlations[bestLag]
            let next = correlations[bestLag + 1]
            let denominator = previous
                - 2 * current
                + next

            if abs(denominator) > 0.000_001 {
                let offset = 0.5
                    * (previous - next)
                    / denominator
                refinedLag += min(max(offset, -1), 1)
            }
        }

        let frequency = sampleRate / refinedLag
        guard frequency.isFinite,
              frequency >= minimumFrequency,
              frequency <= maximumFrequency else {
            return nil
        }

        let exactMIDINote = 69.0
            + 12.0 * log2(frequency / 440.0)
        let midiNote = Int(exactMIDINote.rounded())
        let cents = (exactMIDINote - Double(midiNote)) * 100

        return DetectedPitch(
            midiNote: midiNote,
            frequency: frequency,
            cents: cents
        )
    }
}
