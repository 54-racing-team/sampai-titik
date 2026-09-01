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
    private var loopPlayer: CHHapticAdvancedPatternPlayer?

    var isPlaying: Bool = false
    var isSupportHaptics: Bool = true

    private var currentPattern: CHHapticPattern?
    private var currentFileName: String?

    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?

    init() {
        setupAppLifecycleObservers()
        // Cek kemampuan hardware tanpa menyalakan engine terus menerus (Power Saving)
        isSupportHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    deinit {
        if let backgroundObserver = backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
        }
        if let foregroundObserver = foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }

        stopLooping()
    }

    // MARK: - App Lifecycle Management

    private func setupAppLifecycleObservers() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppBackgrounding()
        }

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppForegrounding()
        }
    }

    private func handleAppBackgrounding() {
        stopLooping()
    }

    private func handleAppForegrounding() {
        if let previousFileName = currentFileName, currentPattern != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startLoopingAHAP(named: previousFileName)
            }
        }
    }

    // MARK: - Haptics Engine Lazy Setup

    private func ensureEngineStarted() throws {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            isSupportHaptics = false
            throw NSError(domain: "HapticError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Haptics not supported"])
        }

        if hapticEngine == nil {
            let engine = try CHHapticEngine()
            engine.stoppedHandler = { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isPlaying = false
                }
            }
            engine.resetHandler = { [weak self] in
                try? self?.hapticEngine?.start()
            }
            hapticEngine = engine
        }

        try hapticEngine?.start()
        isSupportHaptics = true
    }

    /// Starts looping an AHAP file indefinitely
    func startLoopingAHAP(named fileName: String) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        stopLooping()

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "ahap") else {
            print("Could not find \(fileName).ahap")
            return
        }

        do {
            try ensureEngineStarted()

            let data = try Data(contentsOf: url)
            let patternDict = try JSONSerialization.jsonObject(with: data, options: []) as? [CHHapticPattern.Key: Any] ?? [:]
            let pattern = try CHHapticPattern(dictionary: patternDict)

            currentPattern = pattern
            currentFileName = fileName

            guard let engine = hapticEngine else { return }

            loopPlayer = try engine.makeAdvancedPlayer(with: pattern)
            loopPlayer?.loopEnabled = true
            loopPlayer?.loopEnd = pattern.duration

            try loopPlayer?.start(atTime: CHHapticTimeImmediate)

            DispatchQueue.main.async {
                self.isPlaying = true
            }

        } catch {
            print("Failed to loop haptic file: \(error.localizedDescription)")
            stopLooping()
        }
    }

    /// Stops the running loop instantly and stops the haptic engine (Power Saving)
    func stopLooping() {
        do {
            try loopPlayer?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to stop haptic player: \(error.localizedDescription)")
        }

        loopPlayer = nil
        hapticEngine?.stop()
        hapticEngine = nil

        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }

    func clearStoredPattern() {
        currentPattern = nil
        currentFileName = nil
    }
}
