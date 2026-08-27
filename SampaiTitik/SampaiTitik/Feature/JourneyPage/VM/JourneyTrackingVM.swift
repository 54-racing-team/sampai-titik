//
//  JourneyTrackingVM.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 27/08/26.
//

import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class JourneyTrackingVM {
    private let locationManager: LocationManager
    private let alarmScheduler: AlarmSchedulerManager
    private var hasTriggeredArrivalAlarm = false

    var isTrackingActive = false

    var distanceToDestination: CLLocationDistance? {
        locationManager.distanceToDestination
    }

    init(
        locationManager: LocationManager? = nil,
        alarmScheduler: AlarmSchedulerManager? = nil
    ) {
        self.locationManager = locationManager ?? LocationManager()
        self.alarmScheduler = alarmScheduler ?? .shared
    }

    func startTracking(
        departureStation: StationModelDTO,
        destinationStation: StationModelDTO,
        targetRadius: CLLocationDistance = 200
    ) {
        hasTriggeredArrivalAlarm = false
        isTrackingActive = true
        locationManager.onArriveAtDestination = { [weak self] in
            Task { @MainActor in
                await self?.triggerArrivalAlarm(for: destinationStation)
            }
        }
        locationManager.startJourneyTracking(
            departureStation: departureStation,
            destinationStation: destinationStation,
            targetRadius: targetRadius
        )
    }

    func stopTracking() {
        isTrackingActive = false
        locationManager.onArriveAtDestination = nil
        locationManager.stopJourneyTracking()
        alarmScheduler.cancelActiveAlarm()
        AudioManager.shared.stopAlarm()
    }

    private func triggerArrivalAlarm(for destinationStation: StationModelDTO) async {
        guard !hasTriggeredArrivalAlarm else { return }
        hasTriggeredArrivalAlarm = true

        AudioManager.shared.startAlarm(sound: SoundOption.current)

        await alarmScheduler.requestAuthorizationIfNeeded()
        await alarmScheduler.scheduleAlarm(
            after: 1,
            label: "Kamu sudah hampir sampai di \(destinationStation.name)!"
        )
    }
}
