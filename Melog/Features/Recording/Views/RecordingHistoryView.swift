//
//  RecordingHistoryView.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import SwiftData
import SwiftUI

struct RecordingHistoryView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \RecordingRecord.createdAt,
        order: .reverse
    )
    private var records: [RecordingRecord]

    var body: some View {
        List {
            ForEach(records) { record in
                NavigationLink {
                    RecordingDetailView(
                        record: record
                    )
                } label: {
                    RecordingRow(
                        record: record
                    )
                }
            }
            .onDelete(perform: deleteRecords)
        }
        .navigationTitle("녹음 기록")
    }

    private func deleteRecords(
        at offsets: IndexSet
    ) {
        for index in offsets {
            let record = records[index]

            deleteAudioFile(record)
            modelContext.delete(record)
        }

        do {
            try modelContext.save()
        } catch {
            print("녹음 기록 삭제 실패:", error)
        }
    }

    private func deleteAudioFile(
        _ record: RecordingRecord
    ) {
        do {
            try RecordingFileStore.delete(
                fileName: record.fileName
            )
        } catch {
            print("오디오 파일 삭제 실패:", error)
        }
    }
}


struct RecordingRow: View {
    let record: RecordingRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform")
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(
                    .blue.opacity(0.12),
                    in: RoundedRectangle(
                        cornerRadius: 10
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.headline)

                Text(
                    record.createdAt,
                    format: .dateTime
                        .month()
                        .day()
                        .hour()
                        .minute()
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(formatDuration(record.duration))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private func formatDuration(
        _ duration: TimeInterval
    ) -> String {
        let seconds = Int(duration)

        return String(
            format: "%d:%02d",
            seconds / 60,
            seconds % 60
        )
    }
}
