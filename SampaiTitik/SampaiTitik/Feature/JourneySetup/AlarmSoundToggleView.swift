//
//  AlarmSoundToggleView.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 21/08/26.
//

import AVFoundation
import CoreHaptics
import SwiftUI

struct AlarmSoundToggleView: View {
    @State private var hapticsManager = HapticManager()
    @State private var audioManager = AudioManager()
    @State private var isExpandableToggleOn = false
    @State private var showSoundSelectionSheet = false
    @State private var selectedSound: SoundOption = .heartOfHope

    private var hapticFileName: String = "04_Haptics"

    var body: some View {
        ZStack {
            VStack {

                AlarmSetupExpandableToggle(
                    icon: "speaker.wave.2.fill",
                    title: "Bunyi",
                    isOn: $isExpandableToggleOn
                ) {
                    // Sound selection button row
                    Button {
                        showSoundSelectionSheet = true
                    } label: {
                        HStack {
                            Text(selectedSound.displayName)
                                .font(.body)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(.systemBackground))
                        .padding(.leading, 30)
                    }
                    .buttonStyle(.plain)
                }
                .sheet(isPresented: $showSoundSelectionSheet) {
                    SoundSelectionSheet(
                        selectedSound: $selectedSound,
                        audioManager: audioManager,
                        hapticsManager: hapticsManager,
                        hapticFileName: hapticFileName
                    )
                }
                .task {
                    // Load the initial sound
                    audioManager.loadAudio(named: selectedSound.fileName)
                }
                .onChange(of: selectedSound) { _, newSound in
                    // Load new sound when selection changes
                    audioManager.loadAudio(named: newSound.fileName)
                }

                AlarmView()

            }
        }

    }
}

/// UI murni. Tidak tahu detail AlarmKit — cuma manggil AlarmSchedulerManager.
struct AlarmView: View {
    @StateObject private var scheduler = AlarmSchedulerManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text(scheduler.isAuthorized ? "Izin alarm: ✅" : "Izin alarm: ❌")
                .font(.subheadline)

            Button("Set Alarm 3 Detik") {
                Task {
                    await scheduler.requestAuthorizationIfNeeded()
                    await scheduler.scheduleAlarm(
                        after: 3,
                        label: "Waktunya Bangun!",
                        soundTitle: "01_AS_HeartOfHope"
                    )
                }
            }
            .buttonStyle(.borderedProminent)

            if scheduler.activeAlarmID != nil {
                Button("Stop Alarm", role: .destructive) {
                    Task { scheduler.stopActiveAlarm() }
                }
            }
        }
        .padding()
        .task {
            await scheduler.requestAuthorizationIfNeeded()
        }
    }
}

#Preview {
    AlarmSoundToggleView()
}
