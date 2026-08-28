//
//  PrivacyPolicyView.swift
//  Melog
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        List {
            policySection(
                title: "1. 개인정보 처리 원칙",
                content: "Melog는 회원가입이나 로그인을 요구하지 않으며, 사용자를 직접 식별할 수 있는 이름, 이메일 주소, 전화번호 등의 개인정보를 수집하지 않습니다."
            )

            policySection(
                title: "2. 마이크 권한",
                content: "Melog는 사용자가 녹음 기능을 실행할 때 멜로디를 녹음하고 실시간 파형 및 음정을 분석하기 위해 마이크 권한을 사용합니다. 마이크는 사용자가 녹음을 시작한 동안에만 사용되며, 권한은 기기 설정에서 언제든지 변경할 수 있습니다."
            )

            policySection(
                title: "3. 녹음 데이터",
                content: "사용자가 생성한 녹음 파일과 관련 정보는 앱의 로컬 저장 공간에 보관됩니다. 현재 버전의 Melog는 녹음 파일을 외부 서버로 전송하지 않습니다. 앱을 삭제하거나 앱 안에서 녹음 데이터를 삭제하면 해당 데이터가 삭제될 수 있으며, 삭제된 데이터는 복구되지 않을 수 있습니다."
            )

            policySection(
                title: "4. 제3자 제공",
                content: "Melog는 사용자의 개인정보나 녹음 데이터를 제3자에게 판매하거나 제공하지 않습니다. 법령에 따른 적법한 요청이 있는 경우에는 관련 법률이 허용하는 범위에서 처리될 수 있습니다."
            )

            policySection(
                title: "5. 분석 및 진단 정보",
                content: "현재 버전은 맞춤형 광고를 위한 추적 정보를 수집하지 않습니다. 향후 앱 안정성 개선을 위해 충돌 기록이나 익명화된 진단 정보를 사용하게 되는 경우, 적용 전에 본 처리방침을 수정하고 필요한 동의를 받겠습니다."
            )

            policySection(
                title: "6. 이용자의 선택권",
                content: "사용자는 기기 설정에서 마이크 및 알림 권한을 변경할 수 있으며, 앱 안에서 저장된 녹음 기록을 삭제할 수 있습니다. 권한을 허용하지 않아도 앱을 이용할 수 있지만 해당 권한이 필요한 일부 기능은 사용할 수 없습니다."
            )

            policySection(
                title: "7. 아동의 개인정보",
                content: "Melog는 아동의 개인정보를 의도적으로 수집하지 않습니다. 개인정보가 수집된 사실을 알게 된 경우 지체 없이 필요한 조치를 취합니다."
            )

            policySection(
                title: "8. 처리방침 변경",
                content: "기능이나 관련 법령이 변경되는 경우 개인정보 처리방침이 수정될 수 있습니다. 중요한 변경 사항은 앱 안의 공지 또는 업데이트 내역을 통해 안내합니다."
            )

            policySection(
                title: "9. 문의",
                content: "개인정보 처리와 관련된 문의는 설정의 ‘의견 보내기’를 통해 전달할 수 있습니다."
            )

            Section {
                Text("시행일: 2026년 8월 29일")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("개인정보 처리방침")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policySection(
        title: String,
        content: String
    ) -> some View {
        Section(title) {
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(5)
                .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
