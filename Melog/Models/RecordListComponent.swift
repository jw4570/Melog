//
//  RecordListComponent.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import SwiftUI

struct RecordListComponent: ListViewComponent {
    let name: String
    let icon: Image
    let subtitle: String
    
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
                
                Image(systemName: "chevron.down")
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
        return AnyView(Text("Nothing"))
    }
}
