//
//  RecordListComponent.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import Foundation
import SwiftData
import SwiftUI

struct RecordListComponent: ListViewComponent {
    let name: String
    let icon: Image
    let subtitle: String
    let key: Key?
    let bpm: BPM?
    let record: RecordingRecord?

    init(record: RecordingRecord) {
        self.name = record.title
        self.icon = Image(systemName: "music.note")
        self.subtitle = record.createdAt.formatted(
            date: .abbreviated,
            time: .omitted
        )
        self.key = .C
        self.bpm = BPM(bpm: 120)
        self.record = record
    }

    init(
        name: String,
        icon: Image,
        subtitle: String
    ) {
        self.name = name
        self.icon = icon
        self.subtitle = subtitle
        self.key = nil
        self.bpm = nil
        self.record = nil
    }

    func messageView() -> AnyView {
        return AnyView(
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.system(size: 16))
                        .foregroundStyle(.primaryText)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondaryText)
                }

                Spacer()

                if let record {
                    FavoriteButton(record: record)
                    MiniPlaybackButton(record: record)
                }
            }
        )
    }

    func link() -> AnyView {
        if let record {
            return AnyView(RecordingDetailView(record: record))
        }

        return AnyView(Text("녹음 정보가 없습니다."))
    }
}

private struct MiniPlaybackButton: View {
    let record: RecordingRecord

    @State private var playbackService =
        AudioPlaybackService.shared

    private var isThisRecordPlaying: Bool {
        playbackService.loadedRelativePath
            == record.relativePath
        && playbackService.isPlaying
    }

    var body: some View {
        Button {
            if playbackService.loadedRelativePath
                != record.relativePath {
                playbackService.prepare(
                    relativePath: record.relativePath
                )
            }

            guard playbackService.errorMessage == nil else {
                return
            }

            playbackService.togglePlayback()
        } label: {
            Image(
                systemName: isThisRecordPlaying
                    ? "pause.circle.fill"
                    : "play.circle"
            )
            .font(.system(size: 20))
            .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isThisRecordPlaying
                ? "일시정지"
                : "미리 듣기"
        )
    }
}

private struct FavoriteButton: View {
    @Environment(\.modelContext) private var modelContext

    let record: RecordingRecord

    var body: some View {
        Button {
            record.isFavorite.toggle()

            do {
                try modelContext.save()
            } catch {
                record.isFavorite.toggle()
            }
        } label: {
            Image(
                systemName: record.isFavorite
                    ? "star.fill"
                    : "star"
            )
            .font(.system(size: 18))
            .foregroundStyle(
                record.isFavorite
                    ? .yellow
                    : .secondaryText
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            record.isFavorite
                ? "즐겨찾기 해제"
                : "즐겨찾기 추가"
        )
    }
}
