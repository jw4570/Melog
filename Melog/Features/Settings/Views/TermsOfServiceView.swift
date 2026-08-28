//
//  TermsOfServiceView.swift
//  Melog
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        List {
            termsSection(
                title: "1. 목적",
                content: "이 약관은 Melog가 제공하는 멜로디 녹음, 보관, 파형 표시 및 음악 분석 기능의 이용 조건을 정하는 것을 목적으로 합니다."
            )

            termsSection(
                title: "2. 서비스 이용",
                content: "Melog는 회원가입 없이 사용할 수 있습니다. 사용자는 기기와 운영체제가 허용하는 범위에서 녹음 및 보관 기능을 이용할 수 있으며, 일부 기능은 마이크나 알림 등의 시스템 권한이 필요할 수 있습니다."
            )

            termsSection(
                title: "3. 사용자 콘텐츠",
                content: "사용자가 직접 녹음하거나 입력한 멜로디와 관련 자료의 권리는 사용자에게 있습니다. 사용자는 다른 사람의 저작권, 초상권, 개인정보 및 기타 권리를 침해하지 않는 콘텐츠만 기록해야 합니다."
            )

            termsSection(
                title: "4. 금지 행위",
                content: "사용자는 불법적인 목적의 녹음, 타인의 권리를 침해하는 행위, 앱의 정상적인 작동을 방해하는 행위, 앱을 무단으로 복제·변조·역설계하거나 보안 기능을 우회하는 행위를 해서는 안 됩니다."
            )

            termsSection(
                title: "5. 녹음 및 분석 결과",
                content: "음정, 박자, 조성, 악보 및 태그 등의 분석 결과는 기기와 녹음 환경에 따라 정확하지 않을 수 있으며 참고용으로 제공됩니다. 중요한 음악 작업에는 사용자가 결과를 직접 확인해야 합니다."
            )

            termsSection(
                title: "6. 데이터 관리",
                content: "사용자는 중요한 녹음 파일을 별도로 백업할 책임이 있습니다. 기기 변경, 앱 삭제, 저장 공간 부족, 운영체제 오류 또는 사용자의 삭제 조작으로 인해 데이터가 손실될 수 있습니다."
            )

            termsSection(
                title: "7. 서비스 변경 및 중단",
                content: "앱의 품질 개선, 기술적 필요 또는 운영상의 사유로 기능이 추가·변경·중단될 수 있습니다. 중요한 변경 사항은 가능한 범위에서 앱 업데이트 내역 등을 통해 안내합니다."
            )

            termsSection(
                title: "8. 책임의 제한",
                content: "Melog는 합리적인 범위에서 안정적인 서비스를 제공하기 위해 노력합니다. 다만 천재지변, 기기 또는 운영체제 문제, 네트워크 장애, 사용자의 관리 소홀 등 통제하기 어려운 사유로 발생한 손해에 대해서는 관련 법령이 허용하는 범위에서 책임이 제한될 수 있습니다."
            )

            termsSection(
                title: "9. 약관 변경",
                content: "관련 법령이나 서비스 내용이 변경되는 경우 이 약관을 수정할 수 있습니다. 변경된 약관은 앱 안의 공지 또는 업데이트를 통해 안내하며, 변경 이후 서비스를 계속 이용하면 변경된 약관에 동의한 것으로 볼 수 있습니다. 단, 별도의 동의가 필요한 사항은 관련 법령에 따릅니다."
            )

            termsSection(
                title: "10. 준거법",
                content: "이 약관은 대한민국 법령을 따르며, 서비스 이용과 관련한 분쟁은 관련 법령에서 정한 절차에 따라 해결합니다."
            )

            Section {
                Text("시행일: 2026년 8월 29일")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("서비스 이용약관")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func termsSection(
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
        TermsOfServiceView()
    }
}
