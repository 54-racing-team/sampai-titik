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

        let snoozButton = AlarmButton(
            text: "Nanti dulu deh",
            textColor: .white,
            systemImageName: "pause.circle",
        )
        
        let stopButton = AlarmButton(
            text: "Stop",
            textColor: .yellow,
            systemImageName: "play.circle",
        )

        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: label),
            stopButton: stopButton,
            secondaryButton: snoozButton,
            secondaryButtonBehavior: .countdown
        )
        
        let countdown = AlarmPresentation.Countdown(title: "Lanjutin Perjalanan")
        let paused = AlarmPresentation.Paused(
            title: "Perjalanan tertunda",
            resumeButton: AlarmButton(text: "Resume", textColor: .blue, systemImageName: "play.circle"))

        let presentation = AlarmPresentation(alert: alert, countdown: countdown, paused: paused)

        let attributes = AlarmAttributes<MyAlarmMetadata>(
            presentation: presentation,
            metadata: MyAlarmMetadata(label: label),
            tintColor: Color.primary100,
        )

        let alarmSound = AlertConfiguration.AlertSound.named(soundTitle)
        
        return AlarmManager.AlarmConfiguration(
            countdownDuration: .init(preAlert: duration, postAlert: duration),
            attributes: attributes,
            sound: alarmSound
        )
    }
}
