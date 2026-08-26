//
//  SoundSelectionComponents.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 26/08/26.
//

import AVFoundation
import CoreHaptics
import SwiftUI

// MARK: - Sound Selection Sheet

struct SoundSelectionSheet: View {
    @Binding var selectedSound: SoundOption
    var audioManager: AudioManager
    var hapticsManager: HapticManager
    var hapticFileName: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(SoundOption.allCases) { sound in
                    SoundRow(
                        sound: sound,
                        isSelected: sound == selectedSound,
                        audioManager: audioManager,
                        hapticsManager: hapticsManager,
                        hapticFileName: hapticFileName
                    ) {
                        selectedSound = sound
                    }
                }
            }
            .navigationTitle("Pilih Bunyi Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Selesai") {
                        stopPlayback()
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.primary)
                }
            }
        }
        .interactiveDismissDisabled(false)
        .onDisappear {
            stopPlayback()
        }
    }

    private func stopPlayback() {
        audioManager.stop()
        if hapticsManager.isPlaying {
            hapticsManager.stopLooping()
        }

        // Clear stored pattern when sheet is closed (preview mode)
        hapticsManager.clearStoredPattern()
    }
}

// MARK: - Sound Row Component

struct SoundRow: View {
    let sound: SoundOption
    let isSelected: Bool
    var audioManager: AudioManager
    var hapticsManager: HapticManager
    var hapticFileName: String
    let onSelect: () -> Void

    @State private var isPreviewPlaying: Bool = false

    var body: some View {
        Button {
            if isSelected {
                if isPreviewPlaying {
                    // Stop the preview
                    stopPreview()
                } else {
                    // Start the preview
                    startPreview()
                }
            } else {
                // Sound is not selected - just select it, no preview
                onSelect()
            }
        } label: {
            HStack {
                // Checkmark on the left
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.black)
                        .font(.caption)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(sound.displayName)
                        .font(.body)
                        .foregroundStyle(.primary)

                    // Show dynamic hint when selected
                    if isSelected {
                        Text(isPreviewPlaying ? "Tap to stop" : "Tap to preview")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func startPreview() {
        // Clear any previously stored pattern
        hapticsManager.clearStoredPattern()

        // Play audio first
        audioManager.playAudio(named: sound.fileName)

        // Update UI state
        isPreviewPlaying = true

        // Start haptics with a small delay to synchronize with audio
        if hapticsManager.isSupportHaptics {
            // Small delay to ensure audio has started before haptics begin
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.hapticsManager.startLoopingAHAP(named: self.hapticFileName)

                // Schedule automatic stop when audio finishes
                DispatchQueue.main.asyncAfter(deadline: .now() + self.audioManager.duration - 0.1) {
                    self.stopPreview()
                }
            }
        } else {
            // If no haptics, just stop when audio finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + audioManager.duration) {
                self.stopPreview()
            }
        }
    }

    private func stopPreview() {
        // Stop audio
        audioManager.stop()

        // Stop haptics
        if hapticsManager.isPlaying {
            hapticsManager.stopLooping()
        }

        // Update UI state
        isPreviewPlaying = false
    }
}
