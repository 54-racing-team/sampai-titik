//
//  JourneyDetailCard.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import SwiftUI

struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

struct JourneyTimelineIndicator: View {
    let type: StationType
    let isLast: Bool
    
    private var circleColor: Color {
        switch type {
        case .past:
            return Color.gray
        case .current:
            return Color.black
        case .next:
            return Color("MainBlue")
        case .destination:
            return Color.red
        }
    }
    
    var body: some View {
        VStack(spacing: 1) {
            ZStack {
                Circle()
                    .fill(circleColor)
                    .frame(width: 18, height: 18)
                
                Circle()
                    .fill(.white)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 20, height: 22)
            
            if !isLast {
                DashedLine()
                    .stroke(
                        Color.gray.opacity(0.5),
                        style: StrokeStyle(lineWidth: 2, dash: [4, 5])
                    )
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 20)
    }
}

struct StationRow: View {
    let station: JourneyStation
    let isLast: Bool
    
    private var stationFontWeight: Font.Weight {
        switch station.type {
        case .current:
            return .bold
        default:
            return .regular
        }
    }
    
    private var stationTextColor: Color {
        switch station.type {
        case .past:
            return .secondary
        default:
            return .primary
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            JourneyTimelineIndicator(
                type: station.type,
                isLast: isLast
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.system(size: 16, weight: stationFontWeight))
                    .foregroundStyle(stationTextColor)
            }
            .padding(.top, 1)
            .padding(.bottom, isLast ? 0 : 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct JourneyDetailCard: View {
    var viewModel: JourneyPageDetailVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(
                Array(viewModel.stations.enumerated()),
                id: \.element.id
            ) { index, station in
                StationRow(
                    station: station,
                    isLast: viewModel.isLastIndex(index)
                )
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(20)
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding()
    }
}

#Preview {
    ScrollView {
        JourneyDetailCard(
            viewModel: JourneyPageDetailVM()
        )
    }
}
