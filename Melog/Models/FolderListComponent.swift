//
//  BasicFolders.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import SwiftUI

struct FolderListComponent: ListViewComponent {
    let name: String
    let icon: Image
    let count: Int
    
    func messageView() -> AnyView {
        return AnyView(
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
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.secondaryText)
            }
        )
    }
    
    func link() -> AnyView {
        return AnyView(FolderDetailView(folderName: name))
    }
}
