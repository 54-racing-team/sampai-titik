//
//  AlarmToogleCard.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 26/08/26.
//

import SwiftUI

struct AlarmToogleCard: View {
    @State private var isSoundEnabled = true
    @State private var isSheetPresented: Bool = false
    @Binding var soundName: SoundOption

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AlarmSetupExpandableToggle(
                title: "Bunyi",
                isOn: $isSoundEnabled
            ) {
                Button {
                    isSheetPresented.toggle()
                } label: {
                    HStack {
                        Image(systemName: "music.note")

                        Text(soundName.displayName)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .foregroundStyle(.mainBlue)
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.backgroundCard)
        .cornerRadius(26)
        .glassEffect(in: .rect(cornerRadius: 26))
        .animation(.easeInOut(duration: 0.25), value: isSoundEnabled)
        .sheet(isPresented: $isSheetPresented) {
            SoundExpandPageView(selectedSound: $soundName)
        }
    }
}

#Preview {
    AlarmToogleCard(soundName: .constant(.heartOfHope))
}
