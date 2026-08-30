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

private struct SheetSelection: Identifiable {
    let id = UUID()
    let component: any ListViewComponent
}

struct ListView: View {
    let list: [any ListViewComponent]
    let isSheet: Bool

    @State private var selectedItem: SheetSelection?

    init(
        list: [any ListViewComponent],
        isSheet: Bool = false
    ) {
        self.list = list
        self.isSheet = isSheet
    }

    var body: some View {
        VStack(spacing: 14) {
            ForEach(
                Array(list.enumerated()),
                id: \.offset
            ) { index, component in
                VStack(spacing: 0) {
                    if isSheet {
                        row(component)
                            .onTapGesture {
                                selectedItem = SheetSelection(
                                    component: component
                                )
                            }
                    } else {
                        NavigationLink {
                            component.link()
                        } label: {
                            row(component)
                        }
                    }

                    Divider()
                        .overlay(Color.secondaryText)
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
        .sheet(item: $selectedItem) { item in
            NavigationStack {
                item.component.link()
                    .toolbar {
                        ToolbarItem(
                            placement: .confirmationAction
                        ) {
                            Button("완료") {
                                selectedItem = nil
                            }
                        }
                    }
            }
        }
    }

    private func row(
        _ component: any ListViewComponent
    ) -> some View {
        HStack(spacing: 10) {
            component.icon
                .font(.system(size: 20))
                .foregroundStyle(component.iconColor)
                .frame(width: 60)

            component.messageView()
        }
        .contentShape(Rectangle())
    }
}
