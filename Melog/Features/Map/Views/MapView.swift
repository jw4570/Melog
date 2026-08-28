//
//  MapView.swift
//  Melog
//
//  Created by 이주원 on 8/28/26.
//

import SwiftUI

struct MapView: View {
    var body: some View {
        VStack {
            MapPlaceholderView(title: "지도")
        }
        .navigationTitle("지도")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MapPlaceholderView: View {
    let title: String

    var body: some View {
        ContentUnavailableView(
            "준비 중",
            systemImage: "hammer.fill",
            description: Text("\(title) 서비스를 준비 중입니다.")
        )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
