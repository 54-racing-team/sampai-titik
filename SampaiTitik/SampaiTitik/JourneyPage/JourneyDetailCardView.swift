//
//  JourneyDetailCardView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import SwiftUI

struct JourneyTimelineIndicator: View {
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .strokeBorder(.black, lineWidth: 6)
            //            .background(Circle().fill(.white))
                .frame(width: 20, height: 20)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 40))
            }
            .stroke(
                .gray,
                style: StrokeStyle(
                    lineWidth: 2,
                    dash: [8, 3]
                )
            )
            .frame(width: 1, height: 40)
            
            Circle()
                .strokeBorder(Color("Primary100"), lineWidth: 6)
            //            .background(Circle().fill(.white))
                .frame(width: 20, height: 20)
        }
    }
}

struct JourneyDetailCardView: View {
    let origin: String
    let destination: String
    let nextStation: String
    let remainingStation: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Menuju")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack{
                Image(systemName: "train.side.front.car")
                Text(destination)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(20)
            
            HStack {
                Text(remainingStation)
                    .font(.title2.bold())
                Text("sisa pemberhentian")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Sudah berangkat dari \(origin)")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Circle()
                    .strokeBorder(.green, lineWidth: 6)
                //            .background(Circle().fill(.white))
                    .frame(width: 20, height: 20)
                
                Text("Pengingat aktif")
                    .foregroundStyle(.green)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(height: 2)
            
            
            HStack(spacing: 12) {
                VStack {
                    JourneyTimelineIndicator()
                    Spacer()
                }
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(origin)
                            .fontWeight(.semibold)
                        Text("Stasiun saat ini")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                    .frame(alignment: .leading)
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text(nextStation)
                            .fontWeight(.semibold)
                        Text("Pemberhentian berikutnya")
                            .font(.footnote)
                            .fontWeight(.light)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: 110)
            .padding(.horizontal)
            
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(height: 2)
            
            Button{
                
            }label: {
                Text("Lihat detail")
            }
            .foregroundStyle(.black)
        }
        .padding()
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding()
    }
}

#Preview {
    JourneyDetailCardView(
        origin: "Sudirman",
        destination: "Bojong Gede",
        nextStation: "Manggarai",
        remainingStation: "13"
    )
}
