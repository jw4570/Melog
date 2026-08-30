//
//  AudioPlaybackService.swift
//  Melog
//
//  Created by Aside on 8/30/26.
//

import AVFoundation
import Foundation
import Observation

@Observable
@MainActor
final class AudioPlaybackService {
    static let shared = AudioPlaybackService()

    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?

    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var loadedRelativePath: String?
    var errorMessage: String?

    func prepare(relativePath: String) {
        stopProgressTimer()
        audioPlayer?.stop()
        isPlaying = false

        do {
            let fileURL = try RecordingFileStore.url(
                for: relativePath
            )

            guard FileManager.default.fileExists(
                atPath: fileURL.path
            ) else {
                throw CocoaError(.fileReadNoSuchFile)
            }

            let player = try AVAudioPlayer(
                contentsOf: fileURL
            )
            player.prepareToPlay()

            audioPlayer = player
            loadedRelativePath = relativePath
            currentTime = 0
            duration = player.duration
            errorMessage = nil
        } catch {
            audioPlayer = nil
            loadedRelativePath = nil
            errorMessage = "녹음 파일을 불러오지 못했습니다. \(error.localizedDescription)"
        }
    }

    func togglePlayback() {
        guard let audioPlayer else {
            errorMessage = "재생할 녹음 파일이 없습니다."
            return
        }

        if audioPlayer.isPlaying {
            pause()
        } else {
            play(audioPlayer)
        }
    }

    func seek(to time: TimeInterval) {
        guard let audioPlayer else { return }

        let newTime = min(max(time, 0), duration)
        audioPlayer.currentTime = newTime
        currentTime = newTime
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
        isPlaying = false
        stopProgressTimer()

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    private func play(
        _ audioPlayer: AVAudioPlayer
    ) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .default
            )
            try audioSession.setActive(true)

            if currentTime >= duration {
                seek(to: 0)
            }

            guard audioPlayer.play() else {
                errorMessage = "녹음을 재생하지 못했습니다."
                return
            }

            isPlaying = true
            startProgressTimer()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }

    private func startProgressTimer() {
        stopProgressTimer()

        progressTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }

    private func updateProgress() {
        guard let audioPlayer else { return }

        currentTime = audioPlayer.currentTime

        guard audioPlayer.isPlaying else {
            isPlaying = false
            currentTime = duration
            stopProgressTimer()
            return
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}
