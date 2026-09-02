//
//  LocationManager.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 23/08/26.
//

import Foundation
import CoreLocation
import UserNotifications

// MARK: - LocationManager
//
// Tanggung jawab: HANYA mengelola Core Location dengan profil daya adaptif.
//
// Power-saving strategy:
//   1. Idle: allowsBackgroundLocationUpdates = false, stopUpdatingLocation()
//   2. Journey Aktif: allowsBackgroundLocationUpdates = true
//   3. Adaptive Distance Filter & Accuracy:
//      - Jarak > 3 km: distanceFilter = 500m, accuracy = kilometer (Daya sangat hemat di kereta)
//      - Jarak 1 km - 3 km: distanceFilter = 250m, accuracy = hundredMeters
//      - Jarak < 1 km: distanceFilter = 50m, accuracy = nearestTenMeters

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    static let shared = LocationManager()

    private let manager = CLLocationManager()

    // MARK: - Published State
    var userLocation: CLLocation?
    var departureStation: StationModelDTO?
    var destinationStation: StationModelDTO?
    var selectedCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    var targetRadius: CLLocationDistance = 200 {
        didSet { checkArrival() }
    }
    var distanceToDestination: CLLocationDistance?
    var isWithinTargetRadius: Bool = false
    var availableStations: [StationModelDTO] = []
    var onArriveAtDestination: (() -> Void)?

    private var hasTriggeredAlarm: Bool = false
    private var isJourneyTrackingActive: Bool = false

    // MARK: - Init

    override init() {
        super.init()
        self.availableStations = StationModelDTO.loadFromJSON()
        manager.delegate = self
        // Power-saving baseline configuration saat idle
        manager.activityType = .other
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 500
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Permission

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // MARK: - Journey Tracking Lifecycle

    func startJourneyTracking(
        departureStation: StationModelDTO,
        destinationStation: StationModelDTO,
        targetRadius: CLLocationDistance = 500
    ) {
        self.departureStation = departureStation
        self.targetRadius = targetRadius
        isJourneyTrackingActive = true
        hasTriggeredAlarm = false

        setDestination(station: destinationStation)

        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.pausesLocationUpdatesAutomatically = false
            manager.allowsBackgroundLocationUpdates = true
            manager.showsBackgroundLocationIndicator = true
            manager.startUpdatingLocation()
        }
    }

    func stopJourneyTracking() {
        isJourneyTrackingActive = false
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
        manager.showsBackgroundLocationIndicator = false
        manager.pausesLocationUpdatesAutomatically = true
        AudioManager.shared.stopAlarm()
        clearDestination()
    }

    // MARK: - Destination Management

    func setDestination(station: StationModelDTO) {
        destinationStation = station
        destinationCoordinate = station.coordinate
        selectedCoordinate = station.coordinate
        hasTriggeredAlarm = false
        updateDistance()
        checkArrival()
    }

    func setDestination(station: StationModel) {
        setDestination(station: station.toDTO())
    }

    func setDestination(byStationId id: String) {
        if let station = availableStations.first(where: { $0.id.caseInsensitiveCompare(id) == .orderedSame }) {
            setDestination(station: station)
        }
    }

    func setDestination(byStationName name: String) {
        if let station = availableStations.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
            setDestination(station: station)
        }
    }

    func setMockJourney(departureStation: StationModelDTO, destinationStation: StationModelDTO) {
        self.departureStation = departureStation
        userLocation = CLLocation(
            latitude: departureStation.latitude,
            longitude: departureStation.longitude
        )
        setDestination(station: destinationStation)
    }

    func selectDraftDestination(coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
        destinationCoordinate = coordinate
        updateDistance()
    }

    func saveDestination() {
        guard let selected = selectedCoordinate else { return }
        destinationCoordinate = selected
        hasTriggeredAlarm = false
        checkArrival()
    }

    func clearDestination() {
        departureStation = nil
        destinationStation = nil
        selectedCoordinate = nil
        destinationCoordinate = nil
        distanceToDestination = nil
        isWithinTargetRadius = false
    }

    // MARK: - Adaptive Power Profile & Distance Calculation

    private func updateDistance() {
        guard let userLoc = userLocation,
              let activeCoord = destinationCoordinate ?? selectedCoordinate else { return }
        let destLoc = CLLocation(latitude: activeCoord.latitude, longitude: activeCoord.longitude)
        let dist = userLoc.distance(from: destLoc)
        distanceToDestination = dist

        // Terapkan profil daya adaptif berdasarkan jarak ke stasiun tujuan
        applyAdaptivePowerProfile(distance: dist)
    }

    /// Menyesuaikan akurasi dan frekuensi update lokasi berdasarkan jarak ke stasiun tujuan
    /// Berdasarkan rekomendasi Apple Core Location Power Management Guide.
    private func applyAdaptivePowerProfile(distance: CLLocationDistance) {
        guard isJourneyTrackingActive else { return }

        if distance > 3000 {
            // > 3 km: Hemat daya maksimal
            if manager.distanceFilter != 500 {
                manager.distanceFilter = 500
                manager.desiredAccuracy = kCLLocationAccuracyKilometer
            }
        } else if distance > 1000 {
            // 1 km - 3 km
            if manager.distanceFilter != 200 {
                manager.distanceFilter = 200
                manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            }
        } else {
            // < 1 km: Mendekati stasiun
            if manager.distanceFilter != 50 {
                manager.distanceFilter = 50
                manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            }
        }
    }

    private func checkArrival() {
        guard isJourneyTrackingActive, !hasTriggeredAlarm, let dist = distanceToDestination else { return }

        if dist <= targetRadius {
            hasTriggeredAlarm = true
            isJourneyTrackingActive = false
            isWithinTargetRadius = true
            manager.stopUpdatingLocation()
            manager.allowsBackgroundLocationUpdates = false
            manager.showsBackgroundLocationIndicator = false
            manager.pausesLocationUpdatesAutomatically = true
            triggerAlarmNotification()
            onArriveAtDestination?()
        } else {
            isWithinTargetRadius = false
        }
    }

    // MARK: - Notification

    private func triggerAlarmNotification() {
        let content = UNMutableNotificationContent()
        if let stationName = destinationStation?.name {
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

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if isJourneyTrackingActive {
                manager.allowsBackgroundLocationUpdates = true
                manager.showsBackgroundLocationIndicator = true
                manager.startUpdatingLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        updateDistance()
        checkArrival()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }
}

// MARK: - Station Extensions for LocationManager

extension StationModelDTO {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func loadFromJSON(bundle: Bundle = .main) -> [StationModelDTO] {
        guard let url = bundle.url(forResource: "StationsData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dto = try? JSONDecoder().decode(StationsDTO.self, from: data) else {
            return []
        }
        return dto.stations
    }
}

extension StationModel {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func toDTO() -> StationModelDTO {
        StationModelDTO(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            lines: lines.map { KRLLineDTO(line_name: $0.line_name, order: $0.order) }
        )
    }
}
