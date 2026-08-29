//
//  FolderDetailView.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import SwiftUI

struct FolderDetailView: View {
    let folderName: String
    @State var myRecordList: [RecordListComponent] = [
        RecordListComponent(name: "카페", icon: Image(systemName: "music.note"), subtitle: "2026-05-11 · Cm · 126BPM · 00:20"),
        RecordListComponent(name: "운동장", icon: Image(systemName: "music.note"), subtitle: "2026-03-01 · F# · 110BPM · 00:49")
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if(myRecordList.isEmpty) {
                    NoneRecordView(title: folderName)
                } else {
                    ListView(list: myRecordList)
                }
            }
            .padding()
        }
        .navigationTitle(folderName)
        .navigationBarTitleDisplayMode(.inline)
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
