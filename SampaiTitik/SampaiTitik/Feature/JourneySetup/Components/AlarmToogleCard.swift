//
//  AlarmToogleCard.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 26/08/26.
//

import SwiftUI

struct AlarmToogleCard: View {
    @State private var isSoundEnabled = true
    @State private var selectedSound = "Radial (Default)"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AlarmSetupExpandableToggle(
                title: "Bunyi",
                isOn: $isSoundEnabled
            ) {
                NavigationLink {
                    SoundExpandPageView(selectedSound: $selectedSound)
                } label: {
                    HStack {
                        Text(selectedSound)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .glassEffect()
        .animation(.easeInOut(duration: 0.25), value: isSoundEnabled)
    }
}

#Preview {
    AlarmToogleCard()
}
