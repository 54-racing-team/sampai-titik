//
//  AudioConfiguration.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 26/08/26.
//

import Foundation
import AVFoundation
internal import Combine

@Observable
class AudioManager {
    static let shared = AudioManager()

    private var audioPlayer: AVAudioPlayer?
    private(set) var isPlaying: Bool = false
    private(set) var currentFileName: String?
    private(set) var isAudioSessionConfigured: Bool = false

    init() {
        // Power saving: Jangan mengaktifkan audio session secara permanen saat app launch
    }

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            isAudioSessionConfigured = true
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            isAudioSessionConfigured = false
        }
    }

    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            isAudioSessionConfigured = false
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    /// Memulai suara alarm dengan looping tanpa henti sampai dihentikan
    func startAlarm(sound: SoundOption = SoundOption.current) {
        setupAudioSession()
        guard let audioUrl = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else {
            print("Audio file not found: \(sound.fileName).mp3")
            return
        }

        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer?.numberOfLoops = -1 // Looping terus-menerus
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentFileName = sound.fileName
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        } catch {
            print("Failed to play alarm: \(error.localizedDescription)")
        }
    }

    /// Memutar preview suara alarm 1 kali (tidak looping)
    func playPreview(sound: SoundOption) {
        setupAudioSession()
        guard let audioUrl = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else {
            print("Audio file not found: \(sound.fileName).mp3")
            return
        }

        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentFileName = sound.fileName
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        } catch {
            print("Failed to preview sound: \(error.localizedDescription)")
        }
    }

    /// Menghentikan suara alarm dan menonaktifkan audio session (Power Saving)
    func stopAlarm() {
        stop()
    }

    @discardableResult
    func loadAudio(named fileName: String, fileExtension: String = "mp3") -> Bool {
        guard let audioUrl = Bundle.main.path(forResource: fileName, ofType: fileExtension) else {
            print("Audio file not found: \(fileName).\(fileExtension)")
            return false
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioUrl))
            audioPlayer?.prepareToPlay()
            currentFileName = fileName
            return true
        } catch {
            print("Failed to load audio: \(error.localizedDescription)")
            return false
        }
    }

    func play() {
        setupAudioSession()
        guard let player = audioPlayer else {
            print("No audio loaded to play")
            return
        }

        if player.isPlaying {
            player.stop()
            player.currentTime = 0
        }

        player.play()
        DispatchQueue.main.async {
            self.isPlaying = true
        }
    }

    func stop() {
        guard let player = audioPlayer, player.isPlaying else {
            deactivateAudioSession()
            return
        }

        player.stop()
        player.currentTime = 0

        deactivateAudioSession()

        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }

    func playAudio(named fileName: String, fileExtension: String = "mp3") {
        if loadAudio(named: fileName, fileExtension: fileExtension) {
            play()
        }
    }

    func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }

        player.pause()
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }

    var duration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }

    var currentTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }

    var isAudioLoaded: Bool {
        return audioPlayer != nil
    }

    deinit {
        stop()
    }
}
