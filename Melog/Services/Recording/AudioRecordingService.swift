//
//  AudioRecordingService.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import AVFoundation
import Foundation
import Observation

@Observable
@MainActor
final class AudioRecordingService {
    private var recorder: AVAudioRecorder?
    private var meterTimer: Timer?
    private let pitchDetectionService =
        PitchDetectionService()

    private(set) var isRecording = false
    private(set) var elapsedTime: TimeInterval = 0

    // 실시간 파형에 사용할 값
    private(set) var waveformSamples: [CGFloat] = []

    var detectedPitch: DetectedPitch? {
        pitchDetectionService.currentPitch
    }

    var processedPitch: DetectedPitch? {
        pitchDetectionService.processedPitch
    }

    private let maximumSampleCount = 80

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording(
        in relativeDirectory: String? = nil
    ) async throws {
        let permissionGranted =
            await requestPermission()

        guard permissionGranted else {
            throw RecordingError
                .microphonePermissionDenied
        }

        let audioSession =
            AVAudioSession.sharedInstance()

        try audioSession.setCategory(
            .playAndRecord,
            mode: .measurement,
            options: [
                .defaultToSpeaker,
                .allowBluetooth
            ]
        )

        try audioSession.setActive(true)

        let fileURL =
            try RecordingFileStore
                .makeNewRecordingURL(
                    in: relativeDirectory
                )

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey:
                AVAudioQuality.high.rawValue
        ]

        let recorder = try AVAudioRecorder(
            url: fileURL,
            settings: settings
        )

        recorder.isMeteringEnabled = true

        guard recorder.prepareToRecord(),
              recorder.record() else {
            try? audioSession.setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
            throw RecordingError.failedToStart
        }

        self.recorder = recorder
        try? pitchDetectionService.start()
        isRecording = true
        elapsedTime = 0
        waveformSamples = []

        startMetering()
    }


    func stopRecording() throws -> RecordedAudio {
        guard let recorder else {
            throw RecordingError.notRecording
        }

        let fileURL = recorder.url
        let duration = recorder.currentTime

        recorder.stop()
        pitchDetectionService.stop()
        meterTimer?.invalidate()
        meterTimer = nil

        self.recorder = nil
        isRecording = false
        elapsedTime = 0

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )

        return RecordedAudio(
            fileURL: fileURL,
            duration: duration
        )
    }

    func cancelRecording() {
        guard let recorder else {
            return
        }

        let fileURL = recorder.url

        recorder.stop()
        pitchDetectionService.stop()
        meterTimer?.invalidate()
        meterTimer = nil

        try? FileManager.default.removeItem(
            at: fileURL
        )

        self.recorder = nil
        isRecording = false
        elapsedTime = 0
        waveformSamples = []

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    private func startMetering() {
        meterTimer?.invalidate()

        meterTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / 25.0,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateMeter()
            }
        }
    }

    private func updateMeter() {
        guard let recorder,
              recorder.isRecording else {
            return
        }

        recorder.updateMeters()

        let decibels = recorder.averagePower(
            forChannel: 0
        )

        let normalizedPower = normalize(
            decibels: decibels
        )

        waveformSamples.append(normalizedPower)

        if waveformSamples.count > maximumSampleCount {
            waveformSamples.removeFirst(
                waveformSamples.count
                    - maximumSampleCount
            )
        }

        elapsedTime = recorder.currentTime
    }

    private func normalize(
        decibels: Float
    ) -> CGFloat {
        let minimumDecibels: Float = -60

        guard decibels > minimumDecibels else {
            return 0.02
        }

        let normalized =
            (decibels - minimumDecibels)
            / -minimumDecibels

        return CGFloat(
            min(max(normalized, 0.02), 1)
        )
    }
}
