//
//  AlarmMetadata.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 26/08/26.
//

import Foundation
import AlarmKit

/// Data tambahan yang mau kamu simpan bareng alarm (opsional, boleh kosong).
nonisolated struct MyAlarmMetadata: AlarmMetadata {
    let label: String
}
