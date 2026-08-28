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
        modelContext: ModelContext
    ) async {
        if isRecording {
            stopRecording(
                modelContext: modelContext
            )
        } else {
            await startRecording()
        }
    }

    private func startRecording() async {
        do {
            try await recordingService
                .startRecording()

            isRecording = true
            observeRecordingState()
        } catch {
            errorMessage =
                error.localizedDescription
        }
    }

    private func stopRecording(
        modelContext: ModelContext
    ) {
        do {
            let recordedAudio =
                try recordingService.stopRecording()

            let record = RecordingRecord(
                title: makeDefaultTitle(),
                fileName:
                    recordedAudio.fileURL.lastPathComponent,
                duration:
                    recordedAudio.duration
            )

            modelContext.insert(record)

            try modelContext.save()

            isRecording = false
            elapsedTime = 0
            samples = []
        } catch {
            errorMessage =
                error.localizedDescription
        }
    }

    func cancelRecording() {
        recordingService.cancelRecording()

        isRecording = false
        elapsedTime = 0
        samples = []
    }

    private func observeRecordingState() {
        Task {
            while recordingService.isRecording {
                elapsedTime =
                    recordingService.elapsedTime

                samples =
                    recordingService.waveformSamples

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
