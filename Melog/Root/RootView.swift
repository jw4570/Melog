//
//  RootView.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import SwiftUI

struct RootView: View {
    @State private var isShowingIntro = true

    var body: some View {
        ZStack {
            if isShowingIntro {
                IntroView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(
                for: .seconds(3)
            )

            withAnimation(
                .easeInOut(duration: 0.4)
            ) {
                isShowingIntro = false
            }
        }
    }
}

struct IntroView: View {
    private static let messages = [
        "떠오른 멜로디를 기록하세요",
        "지금의 영감을 놓치지 마세요",
        "당신의 멜로디를 들려주세요",
        "허밍으로 음악을 만드세요",
        "머릿속 멜로디를 간직하세요",
        "오늘의 멜로디를 기록해 보세요",
        "멜로디를 로그하다",
        "지금의 영감을 미래로 보내세요"
    ]
    
    @State private var message: String
    
    init() {
        _message = State(
            initialValue: Self.messages.randomElement() ?? Self.messages[0]
        )
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "waveform")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Melog")
                    .font(.system(
                        size: 42,
                        weight: .bold
                    ))

                Text(message + " ― 멜로그")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    RootView()
}
