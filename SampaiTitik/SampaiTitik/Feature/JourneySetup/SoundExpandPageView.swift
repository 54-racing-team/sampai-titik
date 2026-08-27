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
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Card Getaran
                    HStack {
                        Text("Getaran")
                            .font(.body)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text("Tersinkronisasi")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .glassEffect()
                    
                    // Card Pilihan Bunyi
                    VStack(spacing: 0) {
                        ForEach(Array(SoundOption.allCases.enumerated()), id: \.element.id) { index, sound in
                            Button {
                                selectedSound = sound
                                SoundOption.current = sound
                                audioManager.playPreview(sound: sound)
                            } label: {
                                HStack {
                                    Text(sound.displayName)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedSound == sound {
                                        Image(systemName: "checkmark")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(Color("MainBlue"))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if index < SoundOption.allCases.count - 1 {
                                Divider()
                                    .padding(.leading, 20)
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .glassEffect()
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Bunyi")
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
