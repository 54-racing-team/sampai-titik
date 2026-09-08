//
//  JourneyTrackingVM.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 27/08/26.
//

import CoreLocation
import Foundation
import Observation
import UserNotifications
import SwiftData

@MainActor
@Observable
final class JourneyTrackingVM {
    let locationManager: LocationManager
    let alarmScheduler: AlarmSchedulerManager
    private var hasTriggeredArrivalAlarm = false

    var isTrackingActive = false

    var distanceToDestination: CLLocationDistance? {
        locationManager.distanceToDestination
    }

    init(
        locationManager: LocationManager? = nil,
        alarmScheduler: AlarmSchedulerManager? = nil
    ) {
        self.locationManager = locationManager ?? LocationManager.shared
        self.alarmScheduler = alarmScheduler ?? .shared
    }

    func startTracking(
        departureStation: StationModelDTO,
        destinationStation: StationModelDTO,
        modelContext: ModelContext,
        soundName: String? = nil,
        targetRadius: CLLocationDistance? = nil,
    ) async {
        hasTriggeredArrivalAlarm = false
        isTrackingActive = true

        locationManager.onArriveAtDestination = { [weak self] in
            self?.triggerArrivalNotification()
            Task { @MainActor in
                self?.isTrackingActive = false
                
                if let sound = soundName, !sound.isEmpty {
                    await self?.alarmScheduler.scheduleAlarm(
                        after: 3,
                        label: "Kamu sudah di \(self?.locationManager.destinationStation?.name ?? "tujuan")",
                        soundTitle: "\(sound).mp3"
                    )
                } else {
                    LiveActivityManager.shared.endActivity()
                }
                
                self?.addRecentJourney(src: departureStation.name, dst: destinationStation.name, context: modelContext)
            }
        }
        
        // Start location journey
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
        LiveActivityManager.shared.endActivity()
    }    
    
    private func triggerArrivalNotification() {
        // Notify to global observer for navigation & UI transitions
        NotificationCenter.default.post(name: .userArrived, object: nil)
    }
    
    func addRecentJourney(src: String, dst: String, context: ModelContext){
        let newJourney = RecentJourneyModel(
            date: Date(),
            origin: src,
            destination: dst
        )
        
        context.insert(newJourney)
        try? context.save()
        
        let descriptor = FetchDescriptor<RecentJourneyModel>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        
        if let savedJourneys = try? context.fetch(descriptor){
            let journeys = savedJourneys.prefix(5).map {
                recentJourney(date: $0.date, origin: $0.origin, destination: $0.destination)
            }
            WatchManager.shared.sendRecentJourney(journeys)
        }
    }
}
