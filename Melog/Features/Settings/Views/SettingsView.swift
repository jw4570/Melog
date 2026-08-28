//
//  SettingsView.swift
//  Melog
//
//  Created by 이주원 on 8/28/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                settingsSection(
                    title: "권한",
                    components: permissionComponents
                )

                settingsSection(
                    title: "데이터",
                    footer: "녹음 데이터는 사용자의 기기에 저장됩니다.",
                    components: dataComponents
                )

                settingsSection(
                    title: "개인정보 및 약관",
                    components: privacyComponents
                )

                settingsSection(
                    title: "지원",
                    components: supportComponents
                )

                settingsSection(
                    title: "앱 정보",
                    components: appComponents
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.large)
    }

    private func settingsSection(
        title: String,
        footer: String? = nil,
        components: [any ListViewComponent]
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondaryText)
                .padding(.leading, 4)

            ListView(list: components)

            if let footer {
                HStack {
                    Image(systemName: "info.circle")
                    Text(footer)
                }
                .font(.caption)
                .foregroundStyle(.secondaryText)
                .padding(.horizontal, 4)
            }
        }
    }

    private var permissionComponents: [any ListViewComponent] {
        [
            SettingsComponent(
                name: "마이크 접근 권한",
                subtitle: "녹음과 실시간 음정 분석에 사용",
                systemImage: "microphone.fill",
                iconColor: .blue
            ) {
                SettingsPlaceholderView(title: "마이크 접근 권한")
            },
            SettingsComponent(
                name: "알림 설정",
                subtitle: "분석 완료 및 주요 소식 알림",
                systemImage: "bell.fill",
                iconColor: .orange
            ) {
                SettingsPlaceholderView(title: "알림 설정")
            }
        ]
    }

    private var dataComponents: [any ListViewComponent] {
        [
            SettingsComponent(
                name: "저장 공간 관리",
                subtitle: "녹음 파일과 분석 데이터 관리",
                systemImage: "internaldrive.fill",
                iconColor: .indigo
            ) {
                SettingsPlaceholderView(title: "저장 공간 관리")
            },
            SettingsComponent(
                name: "모든 녹음 삭제",
                subtitle: "기기에 저장된 녹음과 분석 결과 삭제",
                systemImage: "trash.fill",
                iconColor: .red,
                isDestructive: true
            ) {
                SettingsPlaceholderView(title: "모든 녹음 삭제")
            }
        ]
    }

    private var privacyComponents: [any ListViewComponent] {
        [
            SettingsComponent(
                name: "개인정보 처리방침",
                systemImage: "hand.raised.fill",
                iconColor: .teal
            ) {
                PrivacyPolicyView()
            },
            SettingsComponent(
                name: "서비스 이용약관",
                systemImage: "doc.text.fill",
                iconColor: .gray
            ) {
                TermsOfServiceView()
            },
            SettingsComponent(
                name: "오픈 소스 라이선스",
                systemImage: "chevron.left.forwardslash.chevron.right",
                iconColor: .purple
            ) {
                SettingsPlaceholderView(title: "오픈 소스 라이선스")
            }
        ]
    }

    private var supportComponents: [any ListViewComponent] {
        [
            SettingsComponent(
                name: "도움말",
                systemImage: "questionmark.circle.fill",
                iconColor: .blue
            ) {
                SettingsPlaceholderView(title: "도움말")
            },
            SettingsComponent(
                name: "의견 보내기",
                systemImage: "envelope.fill",
                iconColor: .mint
            ) {
                SettingsPlaceholderView(title: "의견 보내기")
            },
            SettingsComponent(
                name: "문제 신고",
                systemImage: "exclamationmark.bubble.fill",
                iconColor: .orange
            ) {
                SettingsPlaceholderView(title: "문제 신고")
            }
        ]
    }

    private var appComponents: [any ListViewComponent] {
        [
            SettingsComponent(
                name: "새로운 기능",
                systemImage: "sparkles",
                iconColor: .pink
            ) {
                SettingsPlaceholderView(title: "새로운 기능")
            },
            SettingsComponent(
                name: "버전",
                subtitle: appVersion,
                systemImage: "info.circle.fill",
                iconColor: .gray
            ) {
                SettingsPlaceholderView(title: "앱 정보")
            }
        ]
    }

    private var appVersion: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "1.0"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
