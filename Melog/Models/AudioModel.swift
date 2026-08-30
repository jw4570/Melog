//
//  KeyModel.swift
//  Melog
//
//  Created by 이주원 on 8/30/26.
//

import Foundation

enum Key {
    case C
    case D
    case E
    case F
    case G
    case A
    case B
}

struct DetectedPitch: Sendable, Equatable {
    let midiNote: Int
    let frequency: Double
    let cents: Double

    var scientificName: String {
        let names = [
            "C", "C♯", "D", "D♯", "E", "F",
            "F♯", "G", "G♯", "A", "A♯", "B"
        ]
        let index = (midiNote % 12 + 12) % 12
        return "\(names[index])\(octave)"
    }

    var octave: Int {
        midiNote / 12 - 1
    }
}

struct BPM {
    var bpm: Int = 120

    init(bpm: Int) {
        self.bpm = bpm
    }
}
