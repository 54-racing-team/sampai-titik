//
//  RecentJourneyCardView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 22/08/26.
//

import SwiftUI

struct RecentJourneyCardView: View {
    let origin: String
    let destination: String
    let date: String
    let time: String
    let onReuse: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "train.side.rear.car")
                    .foregroundStyle(Color("MainBlue"))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(origin)
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(Color("MainBlue"))
                        Text(destination)
                    }
                    HStack{
                        Text(date)
                        Text("•")
                        Text(time)
                    }
                    .foregroundStyle(.secondary)
                }
                Spacer()
                
                Button{
                    onReuse()
                } label: {
                    Text("Pakai\nlagi")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("MainBlue"))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding(.horizontal)
    }
}

#Preview {
    RecentJourneyCardView(
        origin: "Pasar Minggu Baru",
        destination: "Metland Telaga Murni",
        date: "Kemarin",
        time: "22.15",
        onReuse: {
            print("Reuse Metland Telaga Murni")
        }
    )
    RecentJourneyCardView(
        origin: "Sudirman",
        destination: "Manggarai",
        date: "Kemarin",
        time: "17.00",
        onReuse: {
            print("Reuse Manggarai")
        }
    )
}

