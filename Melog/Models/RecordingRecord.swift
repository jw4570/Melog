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

    /// Melog 루트 디렉토리를 기준으로 한 파일의 상대 경로
    var relativePath: String

    /// nil이면 루트에 직접 저장된 녹음입니다.
    var folderID: UUID?
    var isFavorite: Bool = false
    var createdAt: Date
    var duration: TimeInterval

    init(
        title: String,
        relativePath: String,
        folderID: UUID? = nil,
        isFavorite: Bool = false,
        createdAt: Date = .now,
        duration: TimeInterval
    ) {
        self.id = UUID()
        self.title = title
        self.relativePath = relativePath
        self.folderID = folderID
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.duration = duration
    }
}
