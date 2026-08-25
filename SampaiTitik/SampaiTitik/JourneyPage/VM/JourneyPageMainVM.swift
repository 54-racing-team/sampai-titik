//
//  JourneyPageMainVM.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import Foundation
import Observation

@Observable
public final class JourneyPageMainVM {
    public var stations: [JourneyStation]
    public var isReminderActive: Bool
    
    public init(
        stations: [JourneyStation] = JourneyStation.sampleStations,
        isReminderActive: Bool = true
    ) {
        self.stations = stations
        self.isReminderActive = isReminderActive
    }
    
    /// Initializer pembantu untuk array nama stasiun dan index stasiun saat ini
    public init(
        stationNames: [String],
        currentStationIndex: Int = 0,
        isReminderActive: Bool = true
    ) {
        self.isReminderActive = isReminderActive
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
    
    /// Backward-compatible initializer untuk origin, destination, nextStation
    public init(
        origin: String,
        destination: String,
        nextStation: String,
        isReminderActive: Bool = true
    ) {
        self.isReminderActive = isReminderActive
        self.stations = [
            JourneyStation(name: origin, type: .current),
            JourneyStation(name: nextStation, type: .next),
            JourneyStation(name: destination, type: .destination)
        ]
    }
    
    // MARK: - Computed Properties
    
    public var currentStationIndex: Int {
        stations.firstIndex(where: { $0.type == .current }) ?? 0
    }
    
    public var currentStation: JourneyStation? {
        guard stations.indices.contains(currentStationIndex) else { return nil }
        return stations[currentStationIndex]
    }
    
    public var currentStationName: String {
        currentStation?.name ?? "-"
    }
    
    public var nextStation: JourneyStation? {
        let nextIndex = currentStationIndex + 1
        guard stations.indices.contains(nextIndex) else { return nil }
        return stations[nextIndex]
    }
    
    public var nextStationName: String {
        nextStation?.name ?? "-"
    }
    
    public var destinationStation: JourneyStation? {
        stations.last
    }
    
    public var destinationName: String {
        destinationStation?.name ?? "-"
    }
    
    public var remainingStationsCount: Int {
        guard !stations.isEmpty else { return 0 }
        let total = stations.count - 1
        return max(0, total - currentStationIndex)
    }
    
    // MARK: - Navigation / Actions
    
    public func makeDetailViewModel() -> JourneyPageDetailVM {
        JourneyPageDetailVM(stations: stations)
    }
    
    public func toggleReminder() {
        isReminderActive.toggle()
    }
}
