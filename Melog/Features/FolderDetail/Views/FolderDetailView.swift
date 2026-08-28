//
//  FolderDetailView.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import SwiftUI

struct FolderDetailView: View {
    let folderName: String
    
    var body: some View {
        FolderPlaceholderView(title: folderName)
    }
}

struct FolderPlaceholderView: View {
    let title: String

    var body: some View {
        ContentUnavailableView(
            "준비 중",
            systemImage: "hammer.fill",
            description: Text("\(title) 폴더가 비었습니다.")
        )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
