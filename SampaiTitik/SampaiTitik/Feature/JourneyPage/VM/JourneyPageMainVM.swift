//
//  JourneyPageMainVM.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class JourneyPageMainVM {
    public var stations: [JourneyStation]
    public var isReminderActive: Bool
    private let trackingViewModel: JourneyTrackingVM

    private var isTrackingStarted = false

    /// Initializer utama — menerima urutan stasiun dari JourneyRouteService via Router.
    public init(
        stations: [JourneyStation],
        isReminderActive: Bool = true
    ) {
        self.stations = stations
        self.isReminderActive = isReminderActive
        self.trackingViewModel = JourneyTrackingVM()
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

    // MARK: - Tracking Control

    public func startTrackingIfPossible() {
        guard !isTrackingStarted,
              isReminderActive,
              let departure = stationDTO(named: currentStationName),
              let destination = stationDTO(named: destinationName) else { return }

        isTrackingStarted = true
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
    
    
    func addRecentJourney(context: ModelContext){
        guard let origin = stations.first?.name,let destination = stations.last?.name else {return}
        
        let recentJourney = RecentJourneyModel(
            date: Date(),
            origin: origin,
            destination: destination
        )
        
        context.insert(recentJourney)
    }
}
