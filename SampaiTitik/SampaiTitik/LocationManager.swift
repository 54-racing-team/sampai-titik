//
//  LocationManager.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 23/08/26.
//

import Foundation
import CoreLocation
import MapKit
import UserNotifications

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    private let manager = CLLocationManager()

    var userLocation: CLLocation?
    var selectedCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    var targetRadius: CLLocationDistance = 200
    var distanceToDestination: CLLocationDistance?
    var estimatedDuration: TimeInterval?
    var isWithinTargetRadius: Bool = false
    private var hasTriggeredAlarm: Bool = false

    var formattedEstimatedDuration: String? {
        guard let duration = estimatedDuration else { return nil }
        let minutes = Int(ceil(duration / 60.0))
        if minutes < 1 {
            return "< 1 menit"
        } else if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) jam"
            } else {
                return "\(hours) jam \(remainingMinutes) menit"
            }
        } else {
            return "\(minutes) menit"
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    func selectDraftDestination(coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
        updateDistance()
        calculateTransitETA()
    }
    
    private func updateDistance() {
        guard let userLoc = userLocation,
              let activeCoord = destinationCoordinate ?? selectedCoordinate else { return }
        let destLoc = CLLocation(latitude: activeCoord.latitude, longitude: activeCoord.longitude)
        distanceToDestination = userLoc.distance(from: destLoc)
    }
    
    func calculateTransitETA() {
        guard let userLoc = userLocation,
              let activeCoord = destinationCoordinate ?? selectedCoordinate else {
            estimatedDuration = nil
            return
        }
        
        let destLoc = CLLocation(latitude: activeCoord.latitude, longitude: activeCoord.longitude)
        let distance = userLoc.distance(from: destLoc)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(location: userLoc, address: nil)
        request.destination = MKMapItem(location: destLoc, address: nil)
        request.transportType = .transit
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            DispatchQueue.main.async {
                if let route = response?.routes.first, route.expectedTravelTime > 0 {
                    self?.estimatedDuration = route.expectedTravelTime
                } else {
                    // Fallback: Estimasi KRL berbasis kecepatan rata-rata (40 km/jam)
                    let averageSpeedMetersPerSecond = 40.0 * 1000.0 / 3600.0
                    self?.estimatedDuration = distance / averageSpeedMetersPerSecond
                }
            }
        }
    }
    
    func saveDestination() {
        guard let selected = selectedCoordinate else { return }
        destinationCoordinate = selected
        hasTriggeredAlarm = false
        calculateTransitETA()
        checkArrival()
    }
    
    func clearDestination() {
        selectedCoordinate = nil
        destinationCoordinate = nil
        distanceToDestination = nil
        estimatedDuration = nil
        isWithinTargetRadius = false
        hasTriggeredAlarm = false
    }

    private func checkArrival() {
        guard let userLoc = userLocation, let destCoord = destinationCoordinate else { return }
        let destLoc = CLLocation(latitude: destCoord.latitude, longitude: destCoord.longitude)
        let distance = userLoc.distance(from: destLoc)
        distanceToDestination = distance

        if distance <= targetRadius {
            isWithinTargetRadius = true
            if !hasTriggeredAlarm {
                hasTriggeredAlarm = true
                triggerAlarmNotification()
            }
        } else {
            isWithinTargetRadius = false
            if distance > targetRadius + 50 { hasTriggeredAlarm = false }
        }
    }
    
    private func triggerAlarmNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Kamu sudah hampir sampai, nih!"
        content.body = "Waktunya siap-siap turun"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(identifier: "ArrivalAlarm", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.allowsBackgroundLocationUpdates = true
            manager.showsBackgroundLocationIndicator = true
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        updateDistance()
        calculateTransitETA()
        checkArrival()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

