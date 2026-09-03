//
//  ConfirmationView.swift
//  SampaiTitik
//
//  Created by Rizki Fitriani on 02/09/26.
//

import SwiftUI

struct ConfirmationView: View {
    var stations: [JourneyStation] = []
    @Environment(Router.self) private var router

    let animationFrames = [
        "slide-transition-confirmation",
        "slide-transition-confirmation-2"
    ]

    private var destinationName: String {
        stations.first(where: { $0.type == .destination })?.name ?? stations.last?.name ?? "Tujuan"
    }

    var body: some View {
        VStack(spacing: 0) {
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
            Text("Tenang! Aku akan ingatkan kamu ketika sudah sampai di Stasiun \(destinationName)")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(30)
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.backgroundBlue))
        .task {
            try? await Task.sleep(for: .seconds(2))
            router.push(.journeyPage(stations: stations))
        }
    }
}

#Preview {
    ConfirmationView()
        .environment(Router())
}
