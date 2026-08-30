//
//  FolderDetailView.swift
//  Melog
//

import SwiftData
import SwiftUI

struct FolderDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \RecordingRecord.createdAt, order: .reverse)
    private var allRecords: [RecordingRecord]

    @Query(sort: \RecordingFolder.name)
    private var allFolders: [RecordingFolder]

    @State private var isEditingRecords = false
    @State private var selectedRecordIDs: Set<UUID> = []
    @State private var isDeleteAlertPresented = false
    @State private var isMoveSheetPresented = false
    @State private var deletionErrorMessage: String?

    private let folder: RecordingFolder?
    private let folderName: String

    init(folder: RecordingFolder) {
        self.folder = folder
        self.folderName = folder.name
    }

    init(folderName: String) {
        self.folder = nil
        self.folderName = folderName
    }

    private var records: [RecordingRecord] {
        guard let folder else {
            switch folderName {
            case "모든 멜로디":
                return allRecords
            case "즐겨찾기":
                return allRecords.filter(\.isFavorite)
            default:
                return []
            }
        }

        return allRecords.filter {
            $0.folderID == folder.id
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if let deletionErrorMessage {
                    Text(deletionErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }

                if records.isEmpty {
                    NoneRecordView(title: folderName)
                } else if isEditingRecords {
                    SelectableRecordList(
                        records: records,
                        selectedRecordIDs: $selectedRecordIDs
                    )
                } else {
                    ListView(
                        list: records.map {
                            RecordListComponent(record: $0)
                        },
                        isSheet: true
                    )
                }
            }
            .padding()
        }
        .navigationTitle(folderName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditingRecords ? "완료" : "편집") {
                    withAnimation {
                        isEditingRecords.toggle()
                    }

                    if !isEditingRecords {
                        selectedRecordIDs.removeAll()
                    }
                }
                .disabled(records.isEmpty)
            }

            if isEditingRecords {
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        selectedRecordIDs.count == records.count
                            ? "선택 해제"
                            : "전체 선택"
                    ) {
                        toggleSelectAll()
                    }
                }

            }
        }
        .safeAreaInset(edge: .bottom) {
            if isEditingRecords {
                RecordSelectionActionBar(
                    selectedCount: selectedRecordIDs.count,
                    onMove: {
                        isMoveSheetPresented = true
                    },
                    onDelete: {
                        isDeleteAlertPresented = true
                    }
                )
            }
        }
        .sheet(isPresented: $isMoveSheetPresented) {
            MoveRecordingsSheet(
                folders: allFolders,
                onMove: moveSelectedRecords
            )
        }
        .alert(
            "선택한 멜로디를 삭제할까요?",
            isPresented: $isDeleteAlertPresented
        ) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                deleteSelectedRecords()
            }
        } message: {
            Text("선택한 \(selectedRecordIDs.count)개의 녹음 파일이 삭제되며 복구할 수 없습니다.")
        }
    }

    private func toggleSelectAll() {
        let allIDs = Set(records.map(\.id))

        if selectedRecordIDs == allIDs {
            selectedRecordIDs.removeAll()
        } else {
            selectedRecordIDs = allIDs
        }
    }

    private func moveSelectedRecords(
        to destinationFolder: RecordingFolder?
    ) {
        deletionErrorMessage = nil
        var failedTitles: [String] = []

        let selectedRecords = records.filter {
            selectedRecordIDs.contains($0.id)
        }

        for record in selectedRecords {
            do {
                record.relativePath = try RecordingFileStore
                    .moveRecording(
                        relativePath: record.relativePath,
                        to: destinationFolder?.relativePath
                    )
                record.folderID = destinationFolder?.id
            } catch {
                failedTitles.append(record.title)
            }
        }

        do {
            try modelContext.save()
        } catch {
            deletionErrorMessage = error.localizedDescription
            return
        }

        selectedRecordIDs.removeAll()
        isEditingRecords = false

        if !failedTitles.isEmpty {
            deletionErrorMessage =
                "이동하지 못한 파일: "
                + failedTitles.joined(separator: ", ")
        }
    }

    private func deleteSelectedRecords() {
        deletionErrorMessage = nil
        var failedTitles: [String] = []

        let selectedRecords = records.filter {
            selectedRecordIDs.contains($0.id)
        }

        for record in selectedRecords {
            do {
                try RecordingFileStore.delete(
                    relativePath: record.relativePath
                )
                modelContext.delete(record)
            } catch {
                failedTitles.append(record.title)
            }
        }

        do {
            try modelContext.save()
        } catch {
            deletionErrorMessage = error.localizedDescription
            return
        }

        selectedRecordIDs.removeAll()

        if failedTitles.isEmpty {
            isEditingRecords = false
        } else {
            deletionErrorMessage =
                "삭제하지 못한 파일: "
                + failedTitles.joined(separator: ", ")
        }
    }
}

private struct RecordSelectionActionBar: View {
    let selectedCount: Int
    let onMove: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("\(selectedCount)개 선택")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button(action: onMove) {
                Label("이동", systemImage: "folder")
            }
            .buttonStyle(.bordered)
            .disabled(selectedCount == 0)

            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(selectedCount == 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

private struct SelectableRecordList: View {
    let records: [RecordingRecord]
    @Binding var selectedRecordIDs: Set<UUID>

    var body: some View {
        VStack(spacing: 14) {
            ForEach(Array(records.enumerated()), id: \.element.id) {
                index,
                record in
                VStack(spacing: 0) {
                    Button {
                        toggleSelection(of: record)
                    } label: {
                        HStack(spacing: 10) {
                            Image(
                                systemName: selectedRecordIDs.contains(record.id)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .font(.system(size: 22))
                            .foregroundStyle(.blue)
                            .frame(width: 60)

                            VStack(alignment: .leading) {
                                Text(record.title)
                                    .font(.system(size: 16))
                                    .foregroundStyle(.primaryText)
                                    .lineLimit(1)

                                Text(
                                    record.createdAt.formatted(
                                        date: .abbreviated,
                                        time: .omitted
                                    )
                                )
                                .font(.caption)
                                .foregroundStyle(.secondaryText)
                            }

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .overlay(Color.secondaryText)
                        .padding(.top, 12)
                        .opacity(index == records.count - 1 ? 0 : 1)
                        .padding(.leading, 64)
                }
            }
        }
        .padding(.top, 12)
        .padding(.vertical, 6)
        .padding(.trailing, 20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.cardBackground)
        }
    }

    private func toggleSelection(
        of record: RecordingRecord
    ) {
        if selectedRecordIDs.contains(record.id) {
            selectedRecordIDs.remove(record.id)
        } else {
            selectedRecordIDs.insert(record.id)
        }
    }
}

private struct NoneRecordView: View {
    let title: String

    var body: some View {
        ContentUnavailableView(
            "허밍에서 시작하세요",
            systemImage: "music.note.slash",
            description: Text("\(title) 폴더가 비었습니다.")
        )
    }
}
