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
        label: String
    ) -> AlarmManager.AlarmConfiguration<MyAlarmMetadata> {

        let stopButton = AlarmButton(
            text: "Matikan Alarm",
            textColor: .white,
            systemImageName: "bell.slash.fill"
        )

        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: label),
            secondaryButton: stopButton,
            secondaryButtonBehavior: .countdown
        )

        let presentation = AlarmPresentation(alert: alert)

        let attributes = AlarmAttributes<MyAlarmMetadata>(
            presentation: presentation,
            metadata: MyAlarmMetadata(label: label),
            tintColor: .red
        )

        // Custom sound: sesuaikan case-nya dengan enum AlertConfiguration.AlertSound
        // di SDK kamu (mis. .named("alarm_song") kalau file ada di bundle,
        // atau .default kalau mau pakai suara sistem).
        return AlarmManager.AlarmConfiguration(
            countdownDuration: .init(preAlert: duration, postAlert: nil),
            attributes: attributes,
            sound: .default
        )
    }
}
