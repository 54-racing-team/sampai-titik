//
//  JourneyPageDetailVM.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import SwiftUI
import Observation

@Observable
public final class JourneyPageDetailVM {
    public var stations: [JourneyStation]
    
    public init(stations: [JourneyStation] = JourneyStation.sampleStations) {
        self.stations = stations
    }
    
    /// Initializer pembantu untuk array nama stasiun dan index stasiun saat ini
    public init(stationNames: [String], currentStationIndex: Int = 0) {
        self.stations = stationNames.enumerated().map { index, name in
            let type: StationType
            if index < currentStationIndex {
                type = .past
            } else if index == currentStationIndex {
                type = .current
            } else if index == stationNames.count - 1 {
                type = .destination
            } else {
                type = .next
            }
            return JourneyStation(name: name, type: type)
        }
    }
    
    // MARK: - Helpers
    
    public func isLastStation(_ station: JourneyStation) -> Bool {
        stations.last?.id == station.id
    }
    
    public func isLastIndex(_ index: Int) -> Bool {
        index == stations.count - 1
    }
    
    public func fontWeight(for type: StationType) -> Font.Weight {
        switch type {
        case .current:
            return .bold
        default:
            return .regular
        }
    }
    
    public func circleColor(for type: StationType) -> Color {
        switch type {
        case .past:
            return Color.gray
        case .current:
            return Color.black
        case .next:
            return Color("Primary100")
        case .destination:
            return Color.red
        }
    }
    
    public func textColor(for type: StationType) -> Color {
        switch type {
        case .past:
            return .secondary
        default:
            return .primary
        }
    }
}
