//
//  SoundExpandSheet.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 26/08/26.
//

import SwiftUI

typealias SoundExpandListView = SoundExpandPageView

struct SoundExpandPageView: View {
    @Binding var selectedSound: SoundOption
    @State private var audioManager = AudioManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Getaran")
                
                Spacer()
                
                Text("Tersinkronisasi")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(.capsule)
            .glassEffect()
            .padding()
            
            List(SoundOption.allCases) { sound in
                Button {
                    selectedSound = sound
                    SoundOption.current = sound
                    audioManager.playPreview(sound: sound)
                } label: {
                    HStack {
                        Text(sound.displayName)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if selectedSound == sound {
                            Image(systemName: "checkmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color("MainBlue"))
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .contentMargins(.top, 0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Bunyi")
        .background(Color("Background"))
        .onDisappear {
            audioManager.stop()
        }
    }
}

#Preview {
    NavigationStack {
        SoundExpandPageView(selectedSound: .constant(.heartOfHope))
    }
}
