//
//  SoundExpandSheet.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 26/08/26.
//

import SwiftUI

let sounds = [
    "Radial (Default)",
    "Arpeggio",
    "Breaking",
    "Canopy",
    "Chalet",
    "Chirp",
    "Daybreak",
    "Departure",
    "Dollop",
    "Journey"
]

struct SoundExpandPageView: View {
    @Binding var selectedSound: String
    
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
            
            List(sounds, id: \.self) { sound in
                Button {
                    selectedSound = sound
                } label: {
                    HStack {
                        Text(sound)
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
        .background(Color("BackgroundBlue"))
    }
}

#Preview {
    NavigationStack {
        SoundExpandPageView(selectedSound: .constant("Radial (Default)"))
    }
}
