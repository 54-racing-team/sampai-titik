//
//  AlarmSoundToggleView.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 21/08/26.
//

import SwiftUI
import AVFoundation

struct AlarmSoundToggleView: View {
    var url: String
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            VStack {
                Button("play") {
                    audioPlayer?.play()
                }
                .buttonStyle(.borderedProminent)
                
                Button("stop") {
                    audioPlayer?.stop()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .task {
            let audioUrl = Bundle.main.url(forResource: url, withExtension: "mp3")!
            audioPlayer = try? AVAudioPlayer(contentsOf: audioUrl)
        }
    }
}

#Preview {
    AlarmSoundToggleView(
        url: "AS_01_HeartOfHope"
    )
}
