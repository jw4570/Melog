//
//  MapView.swift
//  Melog
//
//  Created by 이주원 on 8/28/26.
//

import SwiftData
import SwiftUI

@MainActor
struct RecordView: View {
    @Environment(\.modelContext)
    private var modelContext

    @State
    private var viewModel =
        RecordingViewModel()

    var body: some View {
        VStack(spacing: 24) {
            recordingCard

            Spacer()
        }
        .padding(.top)
        .navigationTitle("허밍")
        .navigationBarTitleDisplayMode(.large)
        .alert(
            "녹음 오류",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(
                viewModel.errorMessage ?? ""
            )
        }
    }

    private var recordingCard: some View {
        ZStack {
            Image(.recordBackground)
                .resizable()
                .allowsHitTesting(false)

            VStack(spacing: 28) {
                Text(
                    viewModel.isRecording
                        ? "녹음 중"
                        : "멜로디를 들려주세요"
                )
                .font(.title2.bold())

                Text(
                    formattedTime(
                        viewModel.elapsedTime
                    )
                )
                .font(
                    .system(
                        size: 40,
                        weight: .medium,
                        design: .monospaced
                    )
                )

                WaveformView(
                    samples: viewModel.samples
                )
                .frame(height: 100)
                .padding(.horizontal)

                RecordButton(
                    isRecording:
                        viewModel.isRecording
                ) {
                    Task { @MainActor in
                        await viewModel.toggleRecording(
                            modelContext: modelContext
                        )
                    }
                }
            }
            .padding()
        }
        .frame(height: 400)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.2),
            radius: 12,
            y: 6
        )
        .padding(.horizontal, 32)
    }

    private func formattedTime(
        _ time: TimeInterval
    ) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }
}


struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        isRecording
                            ? Color.red.opacity(0.2)
                            : Color.blue.opacity(0.2)
                    )
                    .frame(width: 88, height: 88)

                Circle()
                    .fill(
                        isRecording
                            ? Color.red
                            : Color.blue
                    )
                    .frame(
                        width: isRecording ? 42 : 62,
                        height: isRecording ? 42 : 62
                    )

                if isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white)
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: "mic.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isRecording
                ? "녹음 종료"
                : "녹음 시작"
        )
    }
}

struct RecordingDetailView: View {
    let record: RecordingRecord

    var body: some View {
        List {
            Section("녹음 정보") {
                LabeledContent(
                    "제목",
                    value: record.title
                )

                LabeledContent(
                    "녹음 일시"
                ) {
                    Text(
                        record.createdAt,
                        format: .dateTime
                            .year()
                            .month()
                            .day()
                            .hour()
                            .minute()
                    )
                }

                LabeledContent(
                    "재생 시간",
                    value: formattedDuration
                )

                LabeledContent(
                    "파일",
                    value: record.fileName
                )
            }
        }
        .navigationTitle(record.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formattedDuration: String {
        let seconds = Int(record.duration)

        return String(
            format: "%d:%02d",
            seconds / 60,
            seconds % 60
        )
    }
}


#Preview {
    RecordView()
}
