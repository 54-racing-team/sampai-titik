//
//  JourneyPageMainVM.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
public final class JourneyPageMainVM {
    public var stations: [JourneyStation]
    public var isReminderActive: Bool
    private let trackingViewModel: JourneyTrackingVM
    
    public init(
        stations: [JourneyStation]? = nil,
        isReminderActive: Bool = true
    ) {
        self.stations = stations ?? JourneyPageMainVM.defaultJourneyStations()
        self.isReminderActive = isReminderActive
        self.trackingViewModel = JourneyTrackingVM()
        startTrackingIfPossible()
    }
    
    /// Initializer pembantu untuk array nama stasiun dan index stasiun saat ini
    public init(
        stationNames: [String],
        currentStationIndex: Int = 0,
        isReminderActive: Bool = true
    ) {
        self.isReminderActive = isReminderActive
        self.trackingViewModel = JourneyTrackingVM()
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
        startTrackingIfPossible()
    }
    
    /// Backward-compatible initializer untuk origin, destination, nextStation
    public init(
        origin: String,
        destination: String,
        nextStation: String,
        isReminderActive: Bool = true
    ) {
        self.isReminderActive = isReminderActive
        self.trackingViewModel = JourneyTrackingVM()
        self.stations = [
            JourneyStation(name: origin, type: .current),
            JourneyStation(name: nextStation, type: .next),
            JourneyStation(name: destination, type: .destination)
        ]
        startTrackingIfPossible()
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
        if isReminderActive {
            startTrackingIfPossible()
        } else {
            trackingViewModel.stopTracking()
        }
    }

    public func stopJourneyTracking() {
        trackingViewModel.stopTracking()
    }

    private func startTrackingIfPossible() {
        guard isReminderActive,
              let departure = stationDTO(named: currentStationName),
              let destination = stationDTO(named: destinationName) else { return }

        trackingViewModel.startTracking(
            departureStation: departure,
            destinationStation: destination
        )
    }

    private func stationDTO(named name: String) -> StationModelDTO? {
        StationModelDTO.loadFromJSON().first {
            $0.name.caseInsensitiveCompare(name) == .orderedSame
        }
    }

    private static func defaultJourneyStations() -> [JourneyStation] {
        let allStations = StationModelDTO.loadFromJSON()
        let routeStations = route(from: "SUD", to: "PI", in: allStations)

        return routeStations.enumerated().map { index, station in
            let type: StationType
            if index == 0 {
                type = .current
            } else if index == routeStations.count - 1 {
                type = .destination
            } else {
                type = .next
            }

            return JourneyStation(name: station.name, type: type)
        }
    }

    private static func route(from departureID: String, to destinationID: String, in stations: [StationModelDTO]) -> [StationModelDTO] {
        let stationsByID = Dictionary(uniqueKeysWithValues: stations.map { ($0.id, $0) })
        guard stationsByID[departureID] != nil, stationsByID[destinationID] != nil else {
            return JourneyStation.sampleStations.map { station in
                stations.first { $0.name == station.name }
            }.compactMap { $0 }
        }

        var graph: [String: Set<String>] = [:]
        for lineName in Set(stations.flatMap { $0.lines.map(\.line_name) }) {
            let orderedStations = stations
                .compactMap { station -> (station: StationModelDTO, order: Int)? in
                    guard let line = station.lines.first(where: { $0.line_name == lineName }) else { return nil }
                    return (station, line.order)
                }
                .sorted { $0.order < $1.order }

            for pair in zip(orderedStations, orderedStations.dropFirst()) {
                graph[pair.0.station.id, default: []].insert(pair.1.station.id)
                graph[pair.1.station.id, default: []].insert(pair.0.station.id)
            }
        }

        var queue = [departureID]
        var visited = Set([departureID])
        var previousStationID: [String: String] = [:]

        while !queue.isEmpty {
            let currentID = queue.removeFirst()
            if currentID == destinationID { break }

            for neighborID in graph[currentID, default: []].sorted() where !visited.contains(neighborID) {
                visited.insert(neighborID)
                previousStationID[neighborID] = currentID
                queue.append(neighborID)
            }
        }

        guard visited.contains(destinationID) else {
            return [stationsByID[departureID], stationsByID[destinationID]].compactMap { $0 }
        }

        var routeIDs = [destinationID]
        var currentID = destinationID
        while let previousID = previousStationID[currentID] {
            routeIDs.append(previousID)
            currentID = previousID
        }

        return routeIDs.reversed().compactMap { stationsByID[$0] }
    }
}
