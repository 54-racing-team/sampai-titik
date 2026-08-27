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
        setupAudioSession()
    }

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
            isAudioSessionConfigured = true
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            isAudioSessionConfigured = false
        }
    }

    /// Memulai suara alarm dengan looping tanpa henti sampai dihentikan (tetap berbunyi saat silent)
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

    /// Menghentikan suara alarm
    func stopAlarm() {
        stop()
    }

    /// Loads and prepares an audio file for playback
    /// - Parameter fileName: The name of the audio file (without extension)
    /// - Parameter extension: The file extension (default: "mp3")
    /// - Returns: Boolean indicating if the audio was successfully loaded
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

    /// Plays the currently loaded audio file
    func play() {
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

    /// Stops the currently playing audio
    func stop() {
        guard let player = audioPlayer, player.isPlaying else { return }

        player.stop()
        player.currentTime = 0

        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }

    /// Loads and plays an audio file in one operation
    /// - Parameter fileName: The name of the audio file (without extension)
    /// - Parameter fileExtension: The file extension (default: "mp3")
    func playAudio(named fileName: String, fileExtension: String = "mp3") {
        if loadAudio(named: fileName, fileExtension: fileExtension) {
            play()
        }
    }

    /// Pauses the currently playing audio (can be resumed)
    func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }

        player.pause()
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }

    /// Gets the current playback duration
    var duration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }

    /// Gets the current playback time
    var currentTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }

    /// Sets the current playback time
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }

    /// Checks if audio is currently loaded
    var isAudioLoaded: Bool {
        return audioPlayer != nil
    }

    deinit {
        stop()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
