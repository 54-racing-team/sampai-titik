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
    public let alarmScheduler: AlarmSchedulerManager
    
    private let locationManager: LocationManager
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
        targetRadius: CLLocationDistance? = nil,
    ) async {
        hasTriggeredArrivalAlarm = false
        isTrackingActive = true

        locationManager.onArriveAtDestination = { [weak self] in
            self?.triggerArrivalNotification()
            Task { @MainActor in
                self?.isTrackingActive = false
                
                await self?.alarmScheduler.scheduleAlarm(after: 3, label: "Kamu sudah di \(self?.locationManager.destinationStation?.name ?? "tujuan")", soundTitle: "AS_01_HeartOfHope.mp3")
                
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
    }
    
    
    private func triggerArrivalNotification() {
        let content = UNMutableNotificationContent()
        if let stationName = locationManager.destinationStation?.name {
            content.title = "Kamu sudah hampir sampai di \(stationName)!"
        } else {
            content.title = "Kamu sudah hampir sampai, nih!"
        }
        content.body = "Waktunya siap-siap turun"
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let request = UNNotificationRequest(identifier: "ArrivalAlarm", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func addRecentJourney(src: String, dst: String, context: ModelContext){
        let recentJourney = RecentJourneyModel(
            date: Date(),
            origin: src,
            destination: dst
        )
        
        context.insert(recentJourney)
    }
}
