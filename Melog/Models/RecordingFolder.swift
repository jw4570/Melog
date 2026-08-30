//
//  RecordingFolder.swift
//  Melog
//
//  Created by Aside on 8/29/26.
//

import Foundation
import SwiftData

@Model
final class RecordingFolder {
    @Attribute(.unique)
    var id: UUID

    @Attribute(.unique)
    var name: String

    /// Melog 루트 디렉토리를 기준으로 한 상대 디렉토리 경로
    var relativePath: String
    var createdAt: Date

    init(
        name: String,
        relativePath: String,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.name = name
        self.relativePath = relativePath
        self.createdAt = createdAt
    }
}
