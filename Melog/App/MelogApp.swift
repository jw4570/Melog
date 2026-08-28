//
//  MelogApp.swift
//  Melog
//
//  Created by 이주원 on 8/28/26.
//

import SwiftData
import SwiftUI

@main
struct MelogApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(
            for: RecordingRecord.self
        )
    }
}
