//
//  RecordingRecord.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import Foundation
import SwiftData

@Model
final class RecordingRecord {
    @Attribute(.unique)
    var id: UUID

    var title: String
    var fileName: String
    var createdAt: Date
    var duration: TimeInterval

    init(
        title: String,
        fileName: String,
        createdAt: Date = .now,
        duration: TimeInterval
    ) {
        self.id = UUID()
        self.title = title
        self.fileName = fileName
        self.createdAt = createdAt
        self.duration = duration
    }
}
