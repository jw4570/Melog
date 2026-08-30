//
//  RecordingFileStore.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import Foundation

enum RecordingFileStore {
    /// 앱에서 사용하는 단 하나의 파일 저장 루트입니다.
    /// 모든 폴더와 녹음 파일은 이 디렉토리 아래에 생성됩니다.
    static func rootDirectory() throws -> URL {
        let applicationSupportDirectory =
            FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0]

        let rootDirectory = applicationSupportDirectory
            .appendingPathComponent(
                "Melog",
                isDirectory: true
            )

        try createDirectoryIfNeeded(at: rootDirectory)
        return rootDirectory
    }

    @discardableResult
    static func createFolder(named name: String) throws -> String {
        let directoryName = try validatedPathComponent(name)
        let directoryURL = try rootDirectory()
            .appendingPathComponent(
                directoryName,
                isDirectory: true
            )

        try createDirectoryIfNeeded(at: directoryURL)
        return directoryName
    }

    static func renameFolder(
        from oldRelativePath: String,
        to newName: String
    ) throws -> String {
        let newRelativePath = try validatedPathComponent(
            newName
        )

        guard oldRelativePath != newRelativePath else {
            return oldRelativePath
        }

        let oldURL = try url(for: oldRelativePath)
        let newURL = try rootDirectory()
            .appendingPathComponent(
                newRelativePath,
                isDirectory: true
            )

        guard !FileManager.default.fileExists(
            atPath: newURL.path
        ) else {
            throw CocoaError(.fileWriteFileExists)
        }

        try FileManager.default.moveItem(
            at: oldURL,
            to: newURL
        )

        return newRelativePath
    }

    static func deleteFolder(
        relativePath: String
    ) throws {
        let directoryURL = try url(
            for: relativePath
        )

        guard FileManager.default.fileExists(
            atPath: directoryURL.path
        ) else {
            return
        }

        try FileManager.default.removeItem(
            at: directoryURL
        )
    }

    static func makeNewRecordingURL(
        in relativeDirectory: String? = nil
    ) throws -> URL {
        let directoryURL = try directoryURL(
            for: relativeDirectory
        )
        let fileName = "\(UUID().uuidString).m4a"

        return directoryURL.appendingPathComponent(fileName)
    }

    static func relativePath(
        for fileURL: URL
    ) throws -> String {
        let rootPath = try rootDirectory()
            .standardizedFileURL.path
        let filePath = fileURL.standardizedFileURL.path
        let prefix = rootPath + "/"

        guard filePath.hasPrefix(prefix) else {
            throw CocoaError(.fileReadInvalidFileName)
        }

        return String(filePath.dropFirst(prefix.count))
    }

    static func url(
        for relativePath: String
    ) throws -> URL {
        let rootURL = try rootDirectory()
        let fileURL = rootURL
            .appendingPathComponent(relativePath)
            .standardizedFileURL

        guard fileURL.path.hasPrefix(
            rootURL.standardizedFileURL.path + "/"
        ) else {
            throw CocoaError(.fileReadInvalidFileName)
        }

        return fileURL
    }

    static func moveRecording(
        relativePath: String,
        to relativeDirectory: String?
    ) throws -> String {
        let sourceURL = try url(for: relativePath)
        let fileName = sourceURL.lastPathComponent
        let destinationDirectory = try directoryURL(
            for: relativeDirectory
        )
        let destinationURL = destinationDirectory
            .appendingPathComponent(fileName)

        let destinationRelativePath: String
        if let relativeDirectory,
           !relativeDirectory.isEmpty {
            destinationRelativePath = relativeDirectory
                + "/"
                + fileName
        } else {
            destinationRelativePath = fileName
        }

        guard relativePath != destinationRelativePath else {
            return relativePath
        }

        guard !FileManager.default.fileExists(
            atPath: destinationURL.path
        ) else {
            throw CocoaError(.fileWriteFileExists)
        }

        try FileManager.default.moveItem(
            at: sourceURL,
            to: destinationURL
        )

        return destinationRelativePath
    }

    static func delete(
        relativePath: String
    ) throws {
        let fileURL = try url(for: relativePath)

        guard FileManager.default.fileExists(
            atPath: fileURL.path
        ) else {
            return
        }

        try FileManager.default.removeItem(at: fileURL)
    }

    private static func directoryURL(
        for relativeDirectory: String?
    ) throws -> URL {
        guard let relativeDirectory,
              !relativeDirectory.isEmpty else {
            return try rootDirectory()
        }

        let component = try validatedPathComponent(
            relativeDirectory
        )
        let directoryURL = try rootDirectory()
            .appendingPathComponent(
                component,
                isDirectory: true
            )

        try createDirectoryIfNeeded(at: directoryURL)
        return directoryURL
    }

    private static func validatedPathComponent(
        _ value: String
    ) throws -> String {
        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty,
              trimmed != ".",
              trimmed != "..",
              !trimmed.contains("/"),
              !trimmed.contains(":") else {
            throw CocoaError(.fileWriteInvalidFileName)
        }

        return trimmed
    }

    private static func createDirectoryIfNeeded(
        at url: URL
    ) throws {
        guard !FileManager.default.fileExists(
            atPath: url.path
        ) else {
            return
        }

        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
    }
}
