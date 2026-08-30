//
//  RecordingDetailView.swift
//  Melog
//
//  Created by 이주원 on 8/30/26.
//

import Foundation
import SwiftData
import SwiftUI

struct RecordingDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \RecordingFolder.name)
    private var folders: [RecordingFolder]

    let record: RecordingRecord

    @State private var playbackService =
        AudioPlaybackService()
    @State private var editedTitle = ""
    @State private var activeEditAlert: RecordingEditAlert?
    @State private var isMoveSheetPresented = false
    @State private var editErrorMessage: String?

    var body: some View {
        List {
            Section("재생") {
                VStack(spacing: 12) {
                    Slider(
                        value: Binding(
                            get: {
                                playbackService.currentTime
                            },
                            set: {
                                playbackService.seek(to: $0)
                            }
                        ),
                        in: 0...max(
                            playbackService.duration,
                            1
                        )
                    )

                    HStack {
                        Text(
                            formattedTime(
                                playbackService.currentTime
                            )
                        )

                        Spacer()

                        Button {
                            playbackService.togglePlayback()
                        } label: {
                            Image(
                                systemName: playbackService.isPlaying
                                    ? "pause.circle.fill"
                                    : "play.circle.fill"
                            )
                            .font(.system(size: 52))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            playbackService.isPlaying
                                ? "일시정지"
                                : "재생"
                        )

                        Spacer()

                        Text(
                            formattedTime(
                                playbackService.duration
                            )
                        )
                    }
                    .font(.caption.monospacedDigit())
                }
                .padding(.vertical, 8)
            }

            Section("녹음 정보") {
                LabeledContent(
                    "제목",
                    value: record.title
                )

                LabeledContent("녹음 일시") {
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
                    value: record.relativePath
                )
            }
        }
        .navigationTitle(record.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button {
                        editedTitle = record.title
                        activeEditAlert = .rename
                    } label: {
                        Label("이름 변경", systemImage: "pencil")
                    }

                    Button {
                        isMoveSheetPresented = true
                    } label: {
                        Label("이동", systemImage: "folder")
                    }

                    Button(role: .destructive) {
                        activeEditAlert = .delete
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("멜로디 편집")
            }
        }
        .task(id: record.id) {
            AudioPlaybackService.shared.stop()
            playbackService.prepare(
                relativePath: record.relativePath
            )
        }
        .onDisappear {
            playbackService.stop()
        }
        .sheet(isPresented: $isMoveSheetPresented) {
            MoveRecordingsSheet(
                folders: folders,
                onMove: moveRecord
            )
        }
        .alert(
            editAlertTitle,
            isPresented: Binding(
                get: { activeEditAlert != nil },
                set: { isPresented in
                    if !isPresented {
                        activeEditAlert = nil
                    }
                }
            ),
            presenting: activeEditAlert
        ) { editAlert in
            switch editAlert {
            case .rename:
                TextField("멜로디 이름", text: $editedTitle)
                Button("취소", role: .cancel) {}
                Button("저장") {
                    renameRecord()
                }

            case .delete:
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    deleteRecord()
                }
            }
        } message: { editAlert in
            switch editAlert {
            case .rename:
                Text("새 멜로디 이름을 입력하세요.")
            case .delete:
                Text("녹음 파일도 함께 삭제되며 복구할 수 없습니다.")
            }
        }
        .alert(
            "재생 오류",
            isPresented: Binding(
                get: {
                    playbackService.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        playbackService.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인") {
                playbackService.errorMessage = nil
            }
        } message: {
            Text(playbackService.errorMessage ?? "")
        }
        .overlay(alignment: .top) {
            if let editErrorMessage {
                Text(editErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(10)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
    }

    private var editAlertTitle: String {
        switch activeEditAlert {
        case .rename:
            "멜로디 이름 변경"
        case .delete:
            "멜로디를 삭제할까요?"
        case nil:
            ""
        }
    }

    private func renameRecord() {
        editErrorMessage = nil

        let trimmedTitle = editedTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedTitle.isEmpty else {
            editErrorMessage = "멜로디 이름을 입력하세요."
            return
        }

        record.title = trimmedTitle

        do {
            try modelContext.save()
        } catch {
            editErrorMessage = error.localizedDescription
        }
    }

    private func moveRecord(
        to destinationFolder: RecordingFolder?
    ) {
        editErrorMessage = nil
        playbackService.stop()

        do {
            record.relativePath = try RecordingFileStore
                .moveRecording(
                    relativePath: record.relativePath,
                    to: destinationFolder?.relativePath
                )
            record.folderID = destinationFolder?.id
            try modelContext.save()

            playbackService.prepare(
                relativePath: record.relativePath
            )
        } catch {
            editErrorMessage = error.localizedDescription
        }
    }

    private func deleteRecord() {
        editErrorMessage = nil
        playbackService.stop()

        do {
            try RecordingFileStore.delete(
                relativePath: record.relativePath
            )
            modelContext.delete(record)
            try modelContext.save()
            dismiss()
        } catch {
            editErrorMessage = error.localizedDescription
        }
    }

    private var formattedDuration: String {
        formattedTime(record.duration)
    }

    private func formattedTime(
        _ time: TimeInterval
    ) -> String {
        let seconds = Int(time)

        return String(
            format: "%d:%02d",
            seconds / 60,
            seconds % 60
        )
    }
}

private enum RecordingEditAlert {
    case rename
    case delete
}
