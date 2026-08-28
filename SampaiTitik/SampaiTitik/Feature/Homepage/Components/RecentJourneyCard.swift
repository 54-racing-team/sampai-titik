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
                .foregroundStyle(.primary)
                .font(.headline)
            
            dashedLine()
            
            Image(systemName: "record.circle.fill")
                .foregroundStyle(.mainBlue)
                .font(.headline)
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
    let date: String
    let time: String
    let onReuse: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading) {
                HStack {
                    Text(date)
                    Text("•")
                    Text(time)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                RecentJourneySymbol()
                
                VStack(alignment: .leading, spacing: 22) {
                    Text(origin)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(destination)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                }
                .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    onReuse()
                } label: {
                    Text("Pakai lagi")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(4)
                }
                .buttonStyle(.glassProminent)
                .tint(Color("MainBlue"))
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }
}

#Preview {
    RecentJourneyCard(
        origin: "Pasar Minggu Baru",
        destination: "Metland Telaga Murni",
        date: "Kemarin",
        time: "22.15",
        onReuse: {
            print("Reuse Metland Telaga Murni")
        }
    )
}

