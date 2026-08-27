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
    private let destinationRegionIdentifier = "DestinationArrivalRegion"

    var userLocation: CLLocation?
    var departureStation: StationModelDTO?
    var destinationStation: StationModelDTO?
    var selectedCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    var targetRadius: CLLocationDistance = 200 {
        didSet {
            checkArrival()
        }
    }
    var distanceToDestination: CLLocationDistance?
    var estimatedDuration: TimeInterval?
    var isWithinTargetRadius: Bool = false
    var availableStations: [StationModelDTO] = []
    var onArriveAtDestination: (() -> Void)?
    private var hasTriggeredAlarm: Bool = false
    private var isJourneyTrackingActive: Bool = false

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
        self.availableStations = StationModelDTO.loadFromJSON()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.activityType = .otherNavigation
        manager.pausesLocationUpdatesAutomatically = false
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        manager.requestAlwaysAuthorization()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func startJourneyTracking(
        departureStation: StationModelDTO,
        destinationStation: StationModelDTO,
        targetRadius: CLLocationDistance = 200
    ) {
        self.departureStation = departureStation
        self.targetRadius = targetRadius
        isJourneyTrackingActive = true
        hasTriggeredAlarm = false
        requestPermission()
        configureActiveLocationSession()
        setDestination(station: destinationStation)
        startMonitoringDestinationRegion()
    }

    func stopJourneyTracking() {
        isJourneyTrackingActive = false
        stopMonitoringDestinationRegion()
        manager.stopUpdatingLocation()
        AudioManager.shared.stopAlarm()
        clearDestination()
    }
    
    func setDestination(station: StationModelDTO) {
        destinationStation = station
        destinationCoordinate = station.coordinate
        selectedCoordinate = station.coordinate
        hasTriggeredAlarm = false
        updateDistance()
        calculateTransitETA()
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
        calculateTransitETA()
    }
    
    private func updateDistance() {
        guard let userLoc = userLocation,
              let activeCoord = destinationCoordinate ?? selectedCoordinate else { return }
        let destLoc = CLLocation(latitude: activeCoord.latitude, longitude: activeCoord.longitude)
        distanceToDestination = userLoc.distance(from: destLoc)
    }
    
    func calculateTransitETA() {
        if let departureStation, let destinationStation,
           let krlDuration = calculateKRLDuration(from: departureStation, to: destinationStation) {
            estimatedDuration = krlDuration
            return
        }

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
        directions.calculate { [weak self] response, _ in
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

    private func calculateKRLDuration(from departure: StationModelDTO, to destination: StationModelDTO) -> TimeInterval? {
        guard departure.id != destination.id else { return 0 }

        let stationsByID = Dictionary(uniqueKeysWithValues: availableStations.map { ($0.id, $0) })
        var graph: [String: [(stationID: String, duration: TimeInterval)]] = [:]

        for lineName in Set(availableStations.flatMap { $0.lines.map(\.line_name) }) {
            let orderedStations = availableStations
                .compactMap { station -> (station: StationModelDTO, order: Int)? in
                    guard let line = station.lines.first(where: { $0.line_name == lineName }) else { return nil }
                    return (station, line.order)
                }
                .sorted { $0.order < $1.order }

            for pair in zip(orderedStations, orderedStations.dropFirst()) {
                let duration = travelDurationBetween(pair.0.station, pair.1.station)
                graph[pair.0.station.id, default: []].append((pair.1.station.id, duration))
                graph[pair.1.station.id, default: []].append((pair.0.station.id, duration))
            }
        }

        var bestDurations: [String: TimeInterval] = [departure.id: 0]
        var pendingStationIDs = Set(stationsByID.keys)

        while !pendingStationIDs.isEmpty {
            guard let currentID = pendingStationIDs.min(by: {
                (bestDurations[$0] ?? .infinity) < (bestDurations[$1] ?? .infinity)
            }), let currentDuration = bestDurations[currentID] else {
                break
            }

            if currentID == destination.id {
                return currentDuration
            }

            pendingStationIDs.remove(currentID)

            for edge in graph[currentID, default: []] where pendingStationIDs.contains(edge.stationID) {
                let candidateDuration = currentDuration + edge.duration
                if candidateDuration < bestDurations[edge.stationID] ?? .infinity {
                    bestDurations[edge.stationID] = candidateDuration
                }
            }
        }

        return nil
    }

    private func travelDurationBetween(_ firstStation: StationModelDTO, _ secondStation: StationModelDTO) -> TimeInterval {
        let firstLocation = CLLocation(latitude: firstStation.latitude, longitude: firstStation.longitude)
        let secondLocation = CLLocation(latitude: secondStation.latitude, longitude: secondStation.longitude)
        let distance = firstLocation.distance(from: secondLocation)
        let averageSpeedMetersPerSecond = 40.0 * 1000.0 / 3600.0
        let stationStopAllowance: TimeInterval = 45

        return distance / averageSpeedMetersPerSecond + stationStopAllowance
    }
    
    func saveDestination() {
        guard let selected = selectedCoordinate else { return }
        destinationCoordinate = selected
        hasTriggeredAlarm = false
        calculateTransitETA()
        startMonitoringDestinationRegion()
        checkArrival()
    }
    
    func clearDestination() {
        departureStation = nil
        destinationStation = nil
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
                triggerArrivalAlarm()
            }
        } else {
            isWithinTargetRadius = false
            if distance > targetRadius + 50 { hasTriggeredAlarm = false }
        }
    }

    private func triggerArrivalAlarm() {
        AudioManager.shared.startAlarm(sound: SoundOption.current)
        triggerAlarmNotification()
        onArriveAtDestination?()
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

    private func configureActiveLocationSession() {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.allowsBackgroundLocationUpdates = true
            manager.showsBackgroundLocationIndicator = true
            manager.startUpdatingLocation()
        }
    }

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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge, .list])
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            configureActiveLocationSession()
            startMonitoringDestinationRegion()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        updateDistance()
        calculateTransitETA()
        checkArrival()
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
