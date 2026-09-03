//
//  AlarmConfiguration.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 26/08/26.
//

import Foundation
import AlarmKit
import SwiftUI
import ActivityKit

/// Bertanggung jawab MERAKIT AlarmAttributes + AlarmManager.AlarmConfiguration.
/// Tidak tahu-menahu soal scheduling atau UI — murni builder.
enum AlarmConfiguration {

    /// Bikin konfigurasi alarm dengan countdown (misal 3 detik) + custom sound.
    static func makeCountdownConfiguration(
        duration: TimeInterval,
        label: String,
        soundTitle: String,
    ) -> AlarmManager.AlarmConfiguration<MyAlarmMetadata> {

        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: label),
        )

        let presentation = AlarmPresentation(alert: alert)

        let attributes = AlarmAttributes<MyAlarmMetadata>(
            presentation: presentation,
            metadata: MyAlarmMetadata(label: label),
            tintColor: Color.mainBlue,
        )

        let alarmSound = AlertConfiguration.AlertSound.named(soundTitle)
        
        return AlarmManager.AlarmConfiguration(
            countdownDuration: .init(preAlert: duration, postAlert: duration),
            attributes: attributes,
            sound: alarmSound
        )
    }
}
