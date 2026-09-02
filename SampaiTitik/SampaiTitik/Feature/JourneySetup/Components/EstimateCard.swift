//
//  EstimateCard.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 02/09/26.
//

import SwiftUI

struct EstimateCard: View {
    var departureStation: StationModelDTO?
    var destinationStation: StationModelDTO?
    var estimatedDuration: TimeInterval?

    private var formattedDuration: String {
        guard let duration = estimatedDuration else { return "-- menit" }
        let minutes = Int(ceil(duration / 60.0))
        if minutes < 1 {
            return "< 1 menit"
        } else if minutes >= 60 {
            let hours = minutes / 60
            let remaining = minutes % 60
            return remaining == 0 ? "\(hours) jam" : "\(hours) jam \(remaining) menit"
        } else {
            return "\(minutes) menit"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header: Estimasi Perjalanan
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("Estimasi Perjalanan")
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)

                Spacer()

                Text(formattedDuration)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Rute dengan RecentJourneySymbol style
            HStack(spacing: 12) {
                RecentJourneySymbol()

                VStack(alignment: .leading, spacing: 24) {
                    Text(departureStation?.name ?? "Stasiun Asal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text(destinationStation?.name ?? "Stasiun Tujuan")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                .foregroundStyle(.primary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .glassEffect(in: .rect(cornerRadius: 20))
    }
}

#Preview {
    let stations = StationModelDTO.loadFromJSON()
    let dep = stations.first { $0.id == "SUD" } ?? stations[0]
    let dst = stations.first { $0.id == "BKS" } ?? stations[1]

    return ScrollView {
        VStack(spacing: 20) {
            EstimateCard(
                departureStation: dep,
                destinationStation: dst,
                estimatedDuration: 1800
            )
        }
        .padding()
    }
    .background(Color.backgroundBlue)
}
