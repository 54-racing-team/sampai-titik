//
//  ConfirmationView.swift
//  SampaiTitik
//
//  Created by Rizki Fitriani on 02/09/26.
//

import SwiftUI

struct ConfirmationView: View {

    let animationFrames = [
        "slide-transition-confirmation",
        "slide-transition-confirmation-2"
    ]

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            // MARK: Animation
            TimelineView(.animation(minimumInterval: 0.5)) { timeline in
                let frame = Int(
                    timeline.date.timeIntervalSinceReferenceDate * 2
                ) % animationFrames.count

                Image(animationFrames[frame])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 290)
            }

            // MARK: Message
            Text("Tenang! Aku akan ingatkan kamu ketika\nsudah sampai di Stasiun Sudirman")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(.top, 24)

            Spacer()

            // MARK: Button
            CardButton(
                title: "Oke"
            ) {
                // action
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ConfirmationView()
}
