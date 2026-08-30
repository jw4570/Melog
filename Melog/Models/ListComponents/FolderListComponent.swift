//
//  FolderListComponent.swift
//  Melog
//

import SwiftUI

struct FolderListComponent: ListViewComponent {
    let name: String
    let icon: Image
    let count: Int
    let folder: RecordingFolder?

    init(
        folder: RecordingFolder,
        count: Int
    ) {
        self.name = folder.name
        self.icon = Image(systemName: "folder")
        self.count = count
        self.folder = folder
    }

    init(
        name: String,
        systemImage: String,
        count: Int = 0
    ) {
        self.name = name
        self.icon = Image(systemName: systemImage)
        self.count = count
        self.folder = nil
    }

    func messageView() -> AnyView {
        AnyView(
            HStack {
                Text(name)
                    .font(.system(size: 16))
                    .foregroundStyle(.primaryText)
                    .lineLimit(1)

                Spacer()

                Text(String(count))
                    .font(.system(size: 16))
                    .foregroundStyle(.secondaryText)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondaryText)
            }
        )
    }

    func link() -> AnyView {
        if let folder {
            return AnyView(FolderDetailView(folder: folder))
        }

        return AnyView(FolderDetailView(folderName: name))
    }
}
