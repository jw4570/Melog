//
//  RecordViewModel.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class RecordingViewModel {
    private let recordingService:
        AudioRecordingService

    private(set) var isRecording = false
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var samples: [CGFloat] = []
    private(set) var detectedPitch: DetectedPitch?
    private(set) var processedPitch: DetectedPitch?
    private(set) var pitchHeightSamples: [CGFloat] = []
    private(set) var processedPitchSamples: [CGFloat] = []
    private(set) var savedRecord: RecordingRecord?

    var errorMessage: String?

    init() {
        self.recordingService = AudioRecordingService()
    }

    init(
        recordingService: AudioRecordingService
    ) {
        self.recordingService = recordingService
    }

    func toggleRecording(
        modelContext: ModelContext,
        folder: RecordingFolder?
    ) async {
        if isRecording {
            stopRecording(
                modelContext: modelContext,
                folder: folder
            )
        } else {
            await startRecording(
                in: folder?.relativePath
            )
        }
    }

    private func startRecording(
        in relativeDirectory: String?
    ) async {
        do {
            try await recordingService
                .startRecording(
                    in: relativeDirectory
                )

            isRecording = true
            pitchHeightSamples = []
            processedPitchSamples = []
            observeRecordingState()
        } catch {
            errorMessage =
                error.localizedDescription
        }
    }

    private func stopRecording(
        modelContext: ModelContext,
        folder: RecordingFolder?
    ) {
        do {
            let recordedAudio =
                try recordingService.stopRecording()

            isRecording = false
            elapsedTime = 0
            samples = []
            detectedPitch = nil
            processedPitch = nil
            pitchHeightSamples = []
            processedPitchSamples = []

            let record = RecordingRecord(
                title: makeDefaultTitle(),
                relativePath: try RecordingFileStore
                    .relativePath(
                        for: recordedAudio.fileURL
                    ),
                folderID: folder?.id,
                duration: recordedAudio.duration
            )

            modelContext.insert(record)

            try modelContext.save()
            savedRecord = record
        } catch {
            errorMessage =
                error.localizedDescription
        }
    }

    func clearSavedRecord() {
        savedRecord = nil
    }

    func cancelRecording() {
        recordingService.cancelRecording()

        isRecording = false
        elapsedTime = 0
        samples = []
        detectedPitch = nil
        processedPitch = nil
        pitchHeightSamples = []
        processedPitchSamples = []
    }

    private func observeRecordingState() {
        Task {
            while recordingService.isRecording {
                elapsedTime =
                    recordingService.elapsedTime

                samples =
                    recordingService.waveformSamples

                detectedPitch =
                    recordingService.detectedPitch
                processedPitch =
                    recordingService.processedPitch

                if let detectedPitch {
                    let exactMIDINote =
                        CGFloat(detectedPitch.midiNote)
                        + CGFloat(detectedPitch.cents / 100)

                    pitchHeightSamples.append(
                        exactMIDINote
                    )

                    if pitchHeightSamples.count > 100 {
                        pitchHeightSamples.removeFirst(
                            pitchHeightSamples.count - 100
                        )
                    }
                }

                if let processedPitch {
                    let exactProcessedMIDINote =
                        CGFloat(processedPitch.midiNote)
                        + CGFloat(processedPitch.cents / 100)

                    processedPitchSamples.append(
                        exactProcessedMIDINote
                    )

                    if processedPitchSamples.count > 100 {
                        processedPitchSamples.removeFirst(
                            processedPitchSamples.count - 100
                        )
                    }
                }

                try? await Task.sleep(
                    for: .milliseconds(40)
                )
            }
        }
    }

    private func makeDefaultTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat =
            "M월 d일 HH:mm 녹음"

        return formatter.string(from: .now)
    }
}
