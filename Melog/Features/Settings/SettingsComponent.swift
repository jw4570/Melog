//
//  SettingsComponent.swift
//  Melog
//

import SwiftUI

struct SettingsComponent: ListViewComponent {
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

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondaryText)
            }
        )
    }

    func link() -> AnyView {
        destination
    }
}

struct SettingsPlaceholderView: View {
    let title: String

    var body: some View {
        ContentUnavailableView(
            "준비 중",
            systemImage: "hammer.fill",
            description: Text("\(title) 기능을 준비하고 있습니다.")
        )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
