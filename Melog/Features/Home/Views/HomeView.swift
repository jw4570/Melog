//
//  HomeView.swift
//  Melog
//

import Foundation
import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \RecordingFolder.name)
    private var folders: [RecordingFolder]

    @Query private var records: [RecordingRecord]

    @State private var isFolderAlertPresented = false
    @State private var isEditingFolders = false
    @State private var selectedFolderIDs: Set<UUID> = []
    @State private var newFolderName = ""
    @State private var folderErrorMessage: String?
    @State private var renamedFolderName = ""
    @State private var activeEditAlert: FolderEditAlert?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(.melog)
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.primaryText)
                    Spacer()
                }

                VStack(spacing: 8) {
                    if let folderErrorMessage {
                        Text(folderErrorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                    }

                    ListView(list: [
                        BasicFolders.allMelodies.component(
                            count: records.count
                        ),
                        BasicFolders.favorites.component(
                            count: records.filter(\.isFavorite).count
                        )
                    ])

                    Text("나의 폴더")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondaryText)
                        .padding(.top, 10)

                    folderList
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("보관함")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isFolderAlertPresented = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
                .disabled(isEditingFolders)
            }

            ToolbarSpacer(.fixed, placement: .topBarTrailing)

            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditingFolders ? "완료" : "편집") {
                    withAnimation {
                        isEditingFolders.toggle()
                    }

                    if !isEditingFolders {
                        selectedFolderIDs.removeAll()
                    }
                }
                .padding(.horizontal, 16)
                .disabled(folders.isEmpty)
            }

            if isEditingFolders {
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        selectedFolderIDs.count == folders.count
                            ? "선택 해제"
                            : "전체 선택"
                    ) {
                        toggleSelectAllFolders()
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isEditingFolders {
                FolderSelectionActionBar(
                    selectedCount: selectedFolderIDs.count,
                    canRename: selectedFolderIDs.count == 1,
                    onRename: beginRenamingSelectedFolder,
                    onDelete: confirmDeletingSelectedFolders
                )
            }
        }
        .alert("나의 폴더", isPresented: $isFolderAlertPresented) {
            TextField("폴더 이름", text: $newFolderName)
            Button("취소", role: .cancel) {
                newFolderName = ""
            }
            Button("추가") {
                addFolder()
            }
        } message: {
            Text("새 폴더의 이름을 입력하세요.")
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
            case .rename(let folder):
                TextField(
                    "폴더 이름",
                    text: $renamedFolderName
                )
                Button("취소", role: .cancel) {}
                Button("저장") {
                    do {
                        try renameFolder(
                            folder,
                            to: renamedFolderName
                        )
                    } catch {
                        folderErrorMessage =
                            error.localizedDescription
                    }
                }

            case .delete(let selectedFolders):
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    deleteFolders(selectedFolders)
                }
            }
        } message: { editAlert in
            switch editAlert {
            case .rename:
                Text("새 폴더 이름을 입력하세요.")
            case .delete(let selectedFolders):
                Text("선택한 \(selectedFolders.count)개 폴더와 내부의 모든 녹음 파일이 삭제되며 복구할 수 없습니다.")
            }
        }
    }

    @ViewBuilder
    private var folderList: some View {
        if folders.isEmpty {
            HStack {
                Text("폴더를 생성하세요")
                    .foregroundStyle(.blue)
                    .onTapGesture {
                        isFolderAlertPresented = true
                    }
                Spacer()
            }
        } else if isEditingFolders {
            SelectableFolderList(
                folders: folders,
                count: recordingCount,
                selectedFolderIDs: $selectedFolderIDs
            )
        } else {
            ListView(
                list: folders.map { folder in
                    FolderListComponent(
                        folder: folder,
                        count: recordingCount(for: folder)
                    )
                }
            )
        }
    }

    private func toggleSelectAllFolders() {
        let allIDs = Set(folders.map(\.id))

        if selectedFolderIDs == allIDs {
            selectedFolderIDs.removeAll()
        } else {
            selectedFolderIDs = allIDs
        }
    }

    private func beginRenamingSelectedFolder() {
        guard let folder = folders.first(where: {
            selectedFolderIDs.contains($0.id)
        }) else {
            return
        }

        renamedFolderName = folder.name
        activeEditAlert = .rename(folder)
    }

    private func confirmDeletingSelectedFolders() {
        let selectedFolders = folders.filter {
            selectedFolderIDs.contains($0.id)
        }

        guard !selectedFolders.isEmpty else { return }
        activeEditAlert = .delete(selectedFolders)
    }

    private func recordingCount(
        for folder: RecordingFolder
    ) -> Int {
        records.filter {
            $0.folderID == folder.id
        }.count
    }

    private var editAlertTitle: String {
        switch activeEditAlert {
        case .rename:
            "폴더 이름 변경"
        case .delete:
            "폴더를 삭제할까요?"
        case nil:
            ""
        }
    }

    private func addFolder() {
        folderErrorMessage = nil

        let trimmedName = newFolderName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else { return }
        guard !folders.contains(where: { $0.name == trimmedName }) else {
            folderErrorMessage = "같은 이름의 폴더가 이미 있습니다."
            return
        }

        do {
            let relativePath = try RecordingFileStore
                .createFolder(named: trimmedName)
            let folder = RecordingFolder(
                name: trimmedName,
                relativePath: relativePath
            )

            modelContext.insert(folder)
            try modelContext.save()
            newFolderName = ""
        } catch {
            folderErrorMessage = error.localizedDescription
        }
    }

    private func renameFolder(
        _ folder: RecordingFolder,
        to newName: String
    ) throws {
        folderErrorMessage = nil

        let trimmedName = newName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            throw FolderEditError.emptyName
        }

        guard !folders.contains(where: {
            $0.id != folder.id && $0.name == trimmedName
        }) else {
            throw FolderEditError.duplicateName
        }

        let oldName = folder.name
        let oldRelativePath = folder.relativePath
        let folderRecords = records.filter {
            $0.folderID == folder.id
        }
        let oldRecordPaths = Dictionary(
            uniqueKeysWithValues: folderRecords.map {
                ($0.id, $0.relativePath)
            }
        )

        let newRelativePath = try RecordingFileStore
            .renameFolder(
                from: oldRelativePath,
                to: trimmedName
            )

        folder.name = trimmedName
        folder.relativePath = newRelativePath

        for record in folderRecords {
            let fileName = URL(
                fileURLWithPath: record.relativePath
            ).lastPathComponent
            record.relativePath = newRelativePath
                + "/"
                + fileName
        }

        do {
            try modelContext.save()
        } catch {
            try? RecordingFileStore.renameFolder(
                from: newRelativePath,
                to: oldRelativePath
            )
            folder.name = oldName
            folder.relativePath = oldRelativePath

            for record in folderRecords {
                if let oldPath = oldRecordPaths[record.id] {
                    record.relativePath = oldPath
                }
            }

            throw error
        }
    }

    private func deleteFolders(
        _ selectedFolders: [RecordingFolder]
    ) {
        folderErrorMessage = nil
        var failedFolderNames: [String] = []

        for folder in selectedFolders {
            do {
                try RecordingFileStore.deleteFolder(
                    relativePath: folder.relativePath
                )

                for record in records where record.folderID == folder.id {
                    modelContext.delete(record)
                }

                modelContext.delete(folder)
            } catch {
                failedFolderNames.append(folder.name)
            }
        }

        do {
            try modelContext.save()
        } catch {
            folderErrorMessage = error.localizedDescription
            return
        }

        selectedFolderIDs.removeAll()
        activeEditAlert = nil

        if failedFolderNames.isEmpty {
            isEditingFolders = false
        } else {
            folderErrorMessage =
                "삭제하지 못한 폴더: "
                + failedFolderNames.joined(separator: ", ")
        }
    }
}

private struct FolderSelectionActionBar: View {
    let selectedCount: Int
    let canRename: Bool
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("\(selectedCount)개 선택")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button(action: onRename) {
                Label("이름 변경", systemImage: "pencil")
            }
            .buttonStyle(.bordered)
            .disabled(!canRename)

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

private struct SelectableFolderList: View {
    let folders: [RecordingFolder]
    let count: (RecordingFolder) -> Int
    @Binding var selectedFolderIDs: Set<UUID>

    var body: some View {
        VStack(spacing: 14) {
            ForEach(Array(folders.enumerated()), id: \.element.id) {
                index,
                folder in
                VStack(spacing: 0) {
                    Button {
                        toggleSelection(of: folder)
                    } label: {
                        HStack(spacing: 10) {
                            Image(
                                systemName: selectedFolderIDs.contains(folder.id)
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .font(.system(size: 22))
                            .foregroundStyle(.blue)
                            .frame(width: 60)

                            Text(folder.name)
                                .font(.system(size: 16))
                                .foregroundStyle(.primaryText)
                                .lineLimit(1)

                            Spacer()

                            Text(String(count(folder)))
                                .foregroundStyle(.secondaryText)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .overlay(Color.secondaryText)
                        .padding(.top, 12)
                        .opacity(index == folders.count - 1 ? 0 : 1)
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
        of folder: RecordingFolder
    ) {
        if selectedFolderIDs.contains(folder.id) {
            selectedFolderIDs.remove(folder.id)
        } else {
            selectedFolderIDs.insert(folder.id)
        }
    }
}

private enum FolderEditAlert {
    case rename(RecordingFolder)
    case delete([RecordingFolder])
}

private enum FolderEditError: LocalizedError {
    case emptyName
    case duplicateName

    var errorDescription: String? {
        switch self {
        case .emptyName:
            "폴더 이름을 입력하세요."
        case .duplicateName:
            "같은 이름의 폴더가 이미 있습니다."
        }
    }
}

enum BasicFolders {
    case allMelodies
    case favorites

    func component(
        count: Int = 0
    ) -> FolderListComponent {
        switch self {
        case .allMelodies:
            FolderListComponent(
                name: "모든 멜로디",
                systemImage: "waveform",
                count: count
            )
        case .favorites:
            FolderListComponent(
                name: "즐겨찾기",
                systemImage: "star",
                count: count
            )
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(
            for: [
                RecordingFolder.self,
                RecordingRecord.self
            ],
            inMemory: true
        )
}
