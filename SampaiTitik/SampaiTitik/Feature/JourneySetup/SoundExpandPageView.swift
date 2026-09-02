//
//  SoundExpandSheet.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 26/08/26.
//

import SwiftUI

struct SoundExpandPageView: View {
    @Binding var selectedSound: SoundOption
    @State private var audioManager = AudioManager.shared
    
    var body: some View {
        ZStack {
            Color.backgroundBlue
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
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
                    .glassEffect(.regular, in: Capsule())
                    
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
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .glassEffect(in: .rect(cornerRadius: 20))
                }
                .padding()
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
