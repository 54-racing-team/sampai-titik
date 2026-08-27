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
            text: "Saya akan lawan",
            textColor: .white,
            systemImageName: "stop.fill",
        )

        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: label),
            secondaryButton: stopButton,
            secondaryButtonBehavior: .countdown
        )
        
        let countdown = AlarmPresentation.Countdown(title: "Eggs are cooking")
        let paused = AlarmPresentation.Paused(
            title: "Timer paused",
            resumeButton: AlarmButton(text: "Resume", textColor: .blue, systemImageName: "play.circle"))

        let presentation = AlarmPresentation(alert: alert, countdown: countdown, paused: paused)

        let attributes = AlarmAttributes<MyAlarmMetadata>(
            presentation: presentation,
            metadata: MyAlarmMetadata(label: label),
            tintColor: .red,
        )

        // Custom sound: sesuaikan case-nya dengan enum AlertConfiguration.AlertSound
        let alarmSound = AlertConfiguration.AlertSound.named("Chime")
        
        return AlarmManager.AlarmConfiguration(
            countdownDuration: .init(preAlert: duration, postAlert: nil),
            attributes: attributes,
            sound: alarmSound
        )
    }
}
