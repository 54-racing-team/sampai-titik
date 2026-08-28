//
//  HapticsConfiguration.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 26/08/26.
//

import Foundation
import CoreHaptics
import UIKit
internal import Combine

@Observable
class HapticManager {
    private var hapticEngine: CHHapticEngine?
    // Keep a reference to the active loop player
    private var loopPlayer: CHHapticAdvancedPatternPlayer?

    // Track execution state for the SwiftUI UI interface
    var isPlaying: Bool = false
    var isSupportHaptics: Bool = true

    // Store current pattern for restart
    private var currentPattern: CHHapticPattern?
    private var currentFileName: String?

    // App lifecycle observers
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?

    init() {
        setupAppLifecycleObservers()
        prepareHaptics()
    }

    deinit {
        // Remove observers
        if let backgroundObserver = backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
        }
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }

        // Cleanup
        stopLooping()
        hapticEngine?.stop()
    }

    // MARK: - App Lifecycle Management

    private func setupAppLifecycleObservers() {
        // Handle app going to background
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppBackgrounding()
        }

        // Handle app returning to foreground
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppForegrounding()
        }
    }

    private func handleAppBackgrounding() {
        // Stop haptics when app goes to background to save resources
        stopLooping()

        // Don't stop the engine entirely as it can cause issues
        // Just ensure it's in a good state for when we return
        if isPlaying {
            do {
                hapticEngine!.stop()
                print("Haptic engine stopped for backgrounding")
            } catch {
                print("Error stopping engine for background: \(error.localizedDescription)")
            }
        }
    }

    private func handleAppForegrounding() {
        // Restart haptics engine when app returns to foreground
        restartEngineIfNeeded()

        // If we were playing a pattern before, try to restart it
        if let previousFileName = currentFileName, currentPattern != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startLoopingAHAP(named: previousFileName)
            }
        }
    }

    // MARK: - Haptics Engine Setup

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            isSupportHaptics = false
            isPlaying = false
            print("haptics not supported")
            return
        }

        do {
            hapticEngine = try CHHapticEngine()

            // Setup stopped handler with proper reason handling
            hapticEngine?.stoppedHandler = { [weak self] reason in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    switch reason {
                    case .audioSessionInterrupt:
                        print("Haptic engine stopped: audio session interrupted")
                        self.handleEngineStopped()
                    case .applicationSuspended:
                        print("Haptic engine stopped: application suspended")
                        self.handleEngineStopped()
//                    case .notifyWhenPlaybackFinished:
//                        print("Haptic engine stopped: playback finished")
                        // Don't restart for normal completion
                    case .systemError:
                        print("Haptic engine stopped: system error")
                        self.handleEngineStopped()
                    case .gameControllerDisconnect:
                        print("Haptic engine stopped: game controller disconnected")
                    case .idleTimeout:
                        print("Haptic engine stopped: idle timeout")
                        self.handleEngineStopped()
                    @unknown default:
                        print("Haptic engine stopped: unknown reason \(reason)")
                        self.handleEngineStopped()
                    }
                }
            }

            // Setup reset handler
            hapticEngine?.resetHandler = { [weak self] in
                print("Haptic engine reset requested")
                self?.restartEngineIfNeeded()
            }

            try hapticEngine?.start()
            isSupportHaptics = true
            print("Haptic engine started successfully")

        } catch {
            print("Haptic engine failed: \(error.localizedDescription)")
            isSupportHaptics = false
            // Retry once after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.prepareHaptics()
            }
        }
    }

    private func handleEngineStopped() {
        // Update UI state
        self.isPlaying = false

        // Attempt to restart the engine
        restartEngineIfNeeded()
    }

    private func restartEngineIfNeeded() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        // If engine exists but is stopped, try to restart it
        if !isPlaying {
            do {
                try hapticEngine!.start()
                print("Haptic engine restarted successfully")
            } catch {
                print("Failed to restart engine: \(error.localizedDescription)")
                // If restart fails, recreate the engine
                recreateEngine()
            }
        } else if hapticEngine == nil {
            recreateEngine()
        }
    }

    private func recreateEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        do {
            // Stop and cleanup old engine
            hapticEngine?.stop()
            hapticEngine = nil

            // Create new engine
            let newEngine = try CHHapticEngine()

            // Reconfigure handlers
            newEngine.stoppedHandler = { [weak self] reason in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch reason {
                    case .audioSessionInterrupt, .applicationSuspended, .systemError, .idleTimeout:
                        self.handleEngineStopped()
                    default:
                        print("Haptic engine stopped: \(reason)")
                    }
                }
            }

            newEngine.resetHandler = { [weak self] in
                print("Haptic engine reset requested")
                self?.restartEngineIfNeeded()
            }

            try newEngine.start()
            hapticEngine = newEngine
            print("Haptic engine recreated successfully")

        } catch {
            print("Failed to recreate haptic engine: \(error.localizedDescription)")
        }
    }

    /// Starts looping an AHAP file indefinitely
    func startLoopingAHAP(named fileName: String) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        // Ensure engine is running
        restartEngineIfNeeded()

        // Stop any active pattern before spinning up a new one
        stopLooping()

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "ahap") else {
            print("Could not find \(fileName).ahap")
            return
        }

        do {
            // Read the AHAP data from file
            let data = try Data(contentsOf: url)

            let patternDict = try JSONSerialization.jsonObject(with: data, options: []) as? [CHHapticPattern.Key: Any] ?? [:]
            let pattern = try CHHapticPattern(dictionary: patternDict)

            // Store for potential restart
            currentPattern = pattern
            currentFileName = fileName

            // Ensure we have a valid engine
            guard let engine = hapticEngine else {
                print("No haptic engine available")
                return
            }

            loopPlayer = try engine.makeAdvancedPlayer(with: pattern)

            loopPlayer?.loopEnabled = true
            loopPlayer?.loopEnd = pattern.duration // Resets pattern back to 0.0 at its natural end

            try loopPlayer?.start(atTime: CHHapticTimeImmediate)

            DispatchQueue.main.async {
                self.isPlaying = true
            }

            print("Started looping haptic pattern: \(fileName)")

        } catch {
            print("Failed to loop haptic file: \(error.localizedDescription)")

            // Clear state on failure
            currentPattern = nil
            currentFileName = nil
            DispatchQueue.main.async {
                self.isPlaying = false
            }
        }
    }

    /// Stops the running loop instantly
    func stopLooping() {
        guard isPlaying else { return }

        do {
            try loopPlayer?.stop(atTime: CHHapticTimeImmediate)
            loopPlayer = nil

            // Only clear the stored pattern if explicitly stopped (not for restart)
            // We keep currentFileName and currentPattern for app lifecycle restarts

            DispatchQueue.main.async {
                self.isPlaying = false
            }

            print("Stopped haptic looping")

        } catch {
            print("Failed to stop haptic player: \(error.localizedDescription)")
        }
    }

    /// Explicitly clear stored pattern (call when user changes selection)
    func clearStoredPattern() {
        currentPattern = nil
        currentFileName = nil
    }
}
