//
//  AudioConfiguration.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 21/08/26.
//

import Foundation
import AVFoundation

class AudioConfiguration {
    static func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
}
