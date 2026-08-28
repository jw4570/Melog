//
//  MainTabBarView.swift
//  Melog
//
//  Created by 이주원 on 8/28/26.
//

enum Tabs: Hashable {
    case home
    case record
    case map
    case settings
}

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(
                "보관함",
                systemImage: "music.note.list",
                value: .home
            ) {
                NavigationStack {
                    HomeView()
                }
            }
            
            Tab(
                "허밍",
                systemImage: "recordingtape.circle",
                value: .record
            ) {
                NavigationStack {
                    RecordView()
                }
            }
            
            Tab(
                "지도",
                systemImage: "map",
                value: .map
            ) {
                NavigationStack {
                    MapView()
                }
            }

            Tab(
                "설정",
                systemImage: "gearshape",
                value: .settings
            ) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
    }
}


#Preview {
    MainTabView()
}
