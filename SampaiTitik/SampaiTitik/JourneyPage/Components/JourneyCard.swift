//
//  JourneyCard.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import SwiftUI

struct JourneyCard: View {
    var viewModel: JourneyPageMainVM
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Tujuan Akhir")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "train.side.front.car")
                Text(viewModel.destinationName)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(20)
            
            HStack {
                Text("\(viewModel.remainingStationsCount)")
                    .font(.title2.bold())
                Text("sisa pemberhentian")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if viewModel.isReminderActive {
                HStack {
                    Circle()
                        .strokeBorder(.green, lineWidth: 6)
                        .frame(width: 18, height: 18)
                    
                    Text("Pengingat aktif")
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(height: 2)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 14) {
                    JourneyTimelineIndicator(
                        type: .current,
                        isLast: false
                    )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.currentStationName)
                            .fontWeight(.semibold)
                        Text("Stasiun saat ini")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                    .padding(.top, 1)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack(alignment: .top, spacing: 14) {
                    JourneyTimelineIndicator(
                        type: .next,
                        isLast: true
                    )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.nextStationName)
                            .fontWeight(.semibold)
                        Text("Stasiun selanjutnya")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                    .padding(.top, 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 110)
            .padding(.horizontal)
            
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(height: 2)
            
            NavigationLink {
                JourneyDetailPageView(viewModel: viewModel.makeDetailViewModel())
            } label: {
                Text("Lihat detail")
            }
            .tint(.black)
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding()
    }
}

#Preview {
    NavigationStack {
        JourneyCard(viewModel: JourneyPageMainVM())
    }
}
