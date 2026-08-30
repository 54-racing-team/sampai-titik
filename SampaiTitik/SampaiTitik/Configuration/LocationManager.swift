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
// Tanggung jawab: HANYA mengelola Core Location.
// Tidak menangani: route, ETA KRL, stasiun, alarm business logic.
//
// Lifecycle background location:
//   - Idle: allowsBackgroundLocationUpdates = false
//   - Journey aktif: allowsBackgroundLocationUpdates = true
//   - Journey selesai: allowsBackgroundLocationUpdates = false

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    private let manager = CLLocationManager()
    private let destinationRegionIdentifier = "DestinationArrivalRegion"

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
        // Power-saving baseline configuration
        manager.activityType = .otherNavigation
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 100
        manager.pausesLocationUpdatesAutomatically = true
        manager.allowsBackgroundLocationUpdates = false
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Permission
    //
    // Permission lifecycle dipisahkan dari journey lifecycle.
    // Panggil saat pertama kali fitur lokasi dibutuhkan (bukan setiap start journey).

    func requestPermission() {
        manager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // MARK: - Journey Tracking Lifecycle

    func startJourneyTracking(
        departureStation: StationModelDTO,
        destinationStation: StationModelDTO,
        targetRadius: CLLocationDistance = 200
    ) {
        self.departureStation = departureStation
        self.targetRadius = targetRadius
        isJourneyTrackingActive = true
        hasTriggeredAlarm = false

        // Background tracking hanya aktif selama journey
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.allowsBackgroundLocationUpdates = true
            manager.showsBackgroundLocationIndicator = true
            manager.startUpdatingLocation()
        }

        setDestination(station: destinationStation)
        startMonitoringDestinationRegion()
    }

    func stopJourneyTracking() {
        isJourneyTrackingActive = false
        stopMonitoringDestinationRegion()
        manager.stopUpdatingLocation()
        // Kembalikan ke idle state
        manager.allowsBackgroundLocationUpdates = false
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
        startMonitoringDestinationRegion()
        checkArrival()
    }

    func clearDestination() {
        departureStation = nil
        destinationStation = nil
        selectedCoordinate = nil
        destinationCoordinate = nil
        distanceToDestination = nil
        isWithinTargetRadius = false
        hasTriggeredAlarm = false
    }

    // MARK: - Distance & Arrival (Lightweight)

    private func updateDistance() {
        guard let userLoc = userLocation,
              let activeCoord = destinationCoordinate ?? selectedCoordinate else { return }
        let destLoc = CLLocation(latitude: activeCoord.latitude, longitude: activeCoord.longitude)
        distanceToDestination = userLoc.distance(from: destLoc)
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
                triggerArrivalAlarm()
            }
        } else {
            isWithinTargetRadius = false
            if distance > targetRadius + 50 { hasTriggeredAlarm = false }
        }
    }

    // MARK: - Alarm & Notification

    private func triggerArrivalAlarm() {
        AudioManager.shared.startAlarm(sound: SoundOption.current)
        triggerAlarmNotification()
        onArriveAtDestination?()
    }

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

    // MARK: - Region Monitoring

    private func startMonitoringDestinationRegion() {
        guard isJourneyTrackingActive,
              let destinationCoordinate,
              CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }

        stopMonitoringDestinationRegion()

        let radius = min(max(targetRadius, 100), manager.maximumRegionMonitoringDistance)
        let region = CLCircularRegion(
            center: destinationCoordinate,
            radius: radius,
            identifier: destinationRegionIdentifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false

        manager.startMonitoring(for: region)
        manager.requestState(for: region)
    }

    private func stopMonitoringDestinationRegion() {
        for region in manager.monitoredRegions where region.identifier == destinationRegionIdentifier {
            manager.stopMonitoring(for: region)
        }
    }

    private func handleDestinationRegionReached() {
        if let latestLocation = manager.location {
            userLocation = latestLocation
            updateDistance()
        }
        isWithinTargetRadius = true
        guard !hasTriggeredAlarm else { return }
        hasTriggeredAlarm = true
        triggerArrivalAlarm()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if isJourneyTrackingActive {
                manager.allowsBackgroundLocationUpdates = true
                manager.showsBackgroundLocationIndicator = true
                manager.startUpdatingLocation()
                startMonitoringDestinationRegion()
            }
        }
    }

    /// Location update dibuat ringan: hanya update state dan forward ke ViewModel.
    /// Tidak ada route calculation, MKDirections, atau pekerjaan berat di sini.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        updateDistance()   // O(1) — hanya CLLocation.distance
        checkArrival()     // O(1) — hanya bandingkan jarak
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier == destinationRegionIdentifier else { return }
        handleDestinationRegionReached()
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region.identifier == destinationRegionIdentifier, state == .inside else { return }
        handleDestinationRegionReached()
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
