//
//  SettingsListComponent.swift
//  Melog
//

import SwiftUI

struct SettingsListComponent: ListViewComponent {
    let name: String
    let subtitle: String?
    let icon: Image
    let iconColor: Color
    let isDestructive: Bool
    private let destination: AnyView

    init<Destination: View>(
        name: String,
        subtitle: String? = nil,
        systemImage: String,
        iconColor: Color = .blue,
        isDestructive: Bool = false,
        @ViewBuilder destination: () -> Destination
    ) {
        self.name = name
        self.subtitle = subtitle
        self.icon = Image(systemName: systemImage)
        self.iconColor = iconColor
        self.isDestructive = isDestructive
        self.destination = AnyView(destination())
    }

    func messageView() -> AnyView {
        AnyView(
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.system(size: 16))
                        .foregroundStyle(
                            isDestructive ? Color.red : Color.primaryText
                        )

                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondaryText)
                    }
                }

                Spacer(minLength: 8)
            }
        )
    }

    func link() -> AnyView {
        destination
    }
}
