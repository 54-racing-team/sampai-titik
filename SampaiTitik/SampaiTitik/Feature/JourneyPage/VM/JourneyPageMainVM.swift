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
    public var stations: [JourneyStation] {
        didSet {
            // Auto-update Live Activity whenever station state changes during tracking
            if isTrackingStarted {
                updateLiveActivity()
            }
        }
    }
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
        // Update Live Activity to reflect sound toggle change
        updateLiveActivity()
    }

    public func stopJourneyTracking() {
        trackingViewModel.stopTracking()
        LiveActivityManager.shared.endActivity()
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
        
        let nextDTO = stationDTO(named: nextStationName) ?? destination
        
        LiveActivityManager.shared.startJourneyActivity(
            startStation: departure.name,
            endStation: destination.name,
            currentStationCode: departure.id,
            currentStationName: departure.name,
            nextStationCode: nextDTO.id,
            nextStationName: nextStationName,
            isSoundEnabled: isReminderActive
        )
    }
    
    // MARK: - Live Activity Updates
    
    /// Updates the Dynamic Island / Lock Screen Live Activity with the current journey state.
    /// Called automatically when `stations` is mutated (via didSet), and when the reminder is toggled.
    public func updateLiveActivity() {
        guard isTrackingStarted else { return }
        
        let currentDTO = stationDTO(named: currentStationName)
        let nextDTO = stationDTO(named: nextStationName)
        let destinationDTO = stationDTO(named: destinationName)
        
        LiveActivityManager.shared.updateJourneyActivity(
            currentStationCode: currentDTO?.id ?? currentStationName,
            currentStationName: currentStationName,
            nextStationCode: nextDTO?.id ?? destinationDTO?.id ?? "-",
            nextStationName: nextStationName,
            isSoundEnabled: isReminderActive
        )
    }

    private func stationDTO(named name: String) -> StationModelDTO? {
        StationModelDTO.loadFromJSON().first {
            $0.name.caseInsensitiveCompare(name) == .orderedSame
        }
    }
}
