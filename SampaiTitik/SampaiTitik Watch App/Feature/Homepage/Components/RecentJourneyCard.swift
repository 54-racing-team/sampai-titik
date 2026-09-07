//
//  RecentJourneyCardView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 22/08/26.
//

import SwiftUI

struct RecentJourneySymbol: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "record.circle.fill")
            dashedLine()
            Image(systemName: "record.circle.fill")
                .foregroundStyle(Color("MainBlue"))
        }
        .frame(width: 20)
    }
    
    private func dashedLine() -> some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: proxy.size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height))
            }
            .stroke(
                Color.gray.opacity(0.5),
                style: StrokeStyle(lineWidth: 2, dash: [4, 4])
            )
        }
        .frame(width: 2)
    }
}

struct RecentJourneyCard: View {
    let origin: String
    let destination: String
    let date: Date
    let time: Date
    let onReuse: () -> Void
    
    var body: some View {
        Button(action: onReuse) {
            VStack(spacing: 12) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(date, style: .date)
                        Text("•")
                        Text(time, style: .time)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 12) {
                    RecentJourneySymbol()
                    
                    VStack(alignment: .leading, spacing: 22) {
                        Text(origin)
                            .font(.caption2)
                            .fontWeight(.medium)
                    
                        Text(destination)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .glassEffect(in: .rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RecentJourneyCard(
        origin: "Pasar Minggu Baru",
        destination: "Metland Telaga Murni",
        date: Date(),
        time: Date(),
        onReuse: {
            print("Reuse Metland Telaga Murni")
        }
    )
}
