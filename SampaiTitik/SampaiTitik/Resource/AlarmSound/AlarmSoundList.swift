//
//  AlarmSoundList.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 22/08/26.
//

import Foundation

// MARK: - Sound Options

enum SoundOption: String, CaseIterable, Identifiable {
    case heartOfHope = "AS_01_HeartOfHope"
    case prabUtang = "AS_02_PrabUtang"
    case sayaAkanLawan = "AS_03_SayaAkanLawan"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .heartOfHope:
            return "Heart of Hope"
        case .prabUtang:
            return "Saudara Utang"
        case .sayaAkanLawan:
            return "Saya Akan Lawan"
        }
    }

    var fileName: String {
        return rawValue
    }
}
