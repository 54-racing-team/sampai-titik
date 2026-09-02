//
//  JourneySetupPageView.swift
//  SampaiTitik Watch App
//
//  Created by Muhammad Muthi' Nuritzan on 29/08/26.
//

import SwiftUI

private func dashedLine() -> some View {
    GeometryReader { proxy in
        Path { path in
            path.move(to: CGPoint(x: proxy.size.width / 2, y: 0))
            path.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height))
        }
        .stroke(
            Color.secondary,
            style: StrokeStyle(lineWidth: 2, dash: [3, 1])
        )
    }
    .frame(width: 2)
}

struct JourneySymbol: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "record.circle.fill")
            
            dashedLine()
            
            Image(systemName: "record.circle.fill")
                .foregroundStyle(Color.secondaryBlue)
        }
    }
}

struct JourneySetupPageView: View {
    @State var isAlarmOn: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Atur Perjalanan")
                    .font(.title3.bold())
                    .foregroundStyle(.mainBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    JourneySymbol()
                    
                    VStack(alignment: .leading, spacing: 12){
                        Text("Pasar Minggu Baru")
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Metland Telaga Murni")
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle("Alarm", isOn: $isAlarmOn)
                    .padding(10)
                    .glassEffect(.regular, in: Capsule())
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Action
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

#Preview {
    JourneySetupPageView()
}
