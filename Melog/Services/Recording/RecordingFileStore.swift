//
//  RecordingFileStore.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import Foundation

enum RecordingFileStore {
    static func recordingsDirectory() throws -> URL {
        let applicationSupportDirectory =
            FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0]

        let recordingsDirectory =
            applicationSupportDirectory
                .appendingPathComponent(
                    "Recordings",
                    isDirectory: true
                )

        if !FileManager.default.fileExists(
            atPath: recordingsDirectory.path
        ) {
            try FileManager.default.createDirectory(
                at: recordingsDirectory,
                withIntermediateDirectories: true
            )
        }

        return recordingsDirectory
    }

    static func makeNewRecordingURL() throws -> URL {
        let fileName = "\(UUID().uuidString).m4a"

        return try recordingsDirectory()
            .appendingPathComponent(fileName)
    }

    static func url(
        for fileName: String
    ) throws -> URL {
        try recordingsDirectory()
            .appendingPathComponent(fileName)
    }

    static func delete(
        fileName: String
    ) throws {
        let fileURL = try url(for: fileName)

        guard FileManager.default.fileExists(
            atPath: fileURL.path
        ) else {
            return
        }

        try FileManager.default.removeItem(
            at: fileURL
        )
    }
}
