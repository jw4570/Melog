//
//  MelogApp.swift
//  Melog
//
//  Created by 이주원 on 8/28/26.
//

import Foundation
import SwiftData
import SwiftUI

@main
struct MelogApp: App {
    private let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            RecordingFolder.self,
            RecordingRecord.self
        ])

        let applicationSupportDirectory =
            FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0]

        let storeURL = applicationSupportDirectory
            .appendingPathComponent("Melog.store")

        let configuration = ModelConfiguration(
            "Melog",
            schema: schema,
            url: storeURL
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError(
                "SwiftData 저장소 생성 실패: \(error)"
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
