//
//  RecordingError.swift
//  Melog
//
//  Created by 이주원 on 8/29/26.
//

import Foundation

enum RecordingError: LocalizedError {
    case microphonePermissionDenied
    case failedToStart
    case notRecording

    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            "마이크 접근 권한이 필요합니다."

        case .failedToStart:
            "녹음을 시작하지 못했습니다. 실제 기기의 마이크 설정을 확인해 주세요."

        case .notRecording:
            "현재 녹음 중이 아닙니다."
        }
    }
}
