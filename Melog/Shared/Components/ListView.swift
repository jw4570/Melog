//
//  ListView.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import SwiftUI

protocol ListViewComponent {
    var name: String { get }
    var icon: Image { get }
    var iconColor: Color { get }
    func messageView() -> AnyView
    func link() -> AnyView
}

extension ListViewComponent {
    var iconColor: Color { .blue }
}

struct ListView: View {
    let list: [any ListViewComponent]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(
                Array(list.enumerated()),
                id: \.offset
            ) { index, component in
                VStack(spacing: 0) {
                    NavigationLink {
                        component.link()
                    } label: {
                        HStack(spacing: 10) {
                            component.icon
                                .font(.system(size: 20))
                                .foregroundStyle(component.iconColor)
                                .frame(width: 60)
                            
                            component.messageView()
                        }
                        .contentShape(Rectangle())
                    }
                    
                    Divider()
                        .overlay(Color.primaryText)
                        .padding(.top, 12)
                        .opacity(
                            index == list.count - 1
                                ? 0
                                : 1
                        )
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
}
