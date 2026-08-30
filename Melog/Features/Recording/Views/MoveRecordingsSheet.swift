//
//  MoveRecordingsSheet.swift
//  Melog
//
//  Created by Aside on 8/30/26.
//

import SwiftUI

struct MoveRecordingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let folders: [RecordingFolder]
    let onMove: (RecordingFolder?) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("이동할 위치") {
                    destinationButton(
                        name: "Melog 루트",
                        systemImage: "tray",
                        folder: nil
                    )

                    ForEach(folders, id: \.id) { folder in
                        destinationButton(
                            name: folder.name,
                            systemImage: "folder",
                            folder: folder
                        )
                    }
                }
            }
            .navigationTitle("멜로디 이동")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func destinationButton(
        name: String,
        systemImage: String,
        folder: RecordingFolder?
    ) -> some View {
        Button {
            onMove(folder)
            dismiss()
        } label: {
            Label(name, systemImage: systemImage)
        }
    }
}
