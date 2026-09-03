//
//  JourneyPageMainVM.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import CoreLocation
import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class JourneyPageMainVM {
    public var stations: [JourneyStation]
    public var isReminderActive: Bool
    let trackingViewModel: JourneyTrackingVM

    private var isTrackingStarted = false

    /// Index stasiun yang sedang aktif (current), di-track secara manual
    private(set) var activeStationIndex: Int = 0

    /// Radius proximity untuk mendeteksi kedatangan tepat di stasiun (meter)
    let stationProximityRadius: CLLocationDistance = 400

    /// Initializer utama — menerima urutan stasiun dari JourneyRouteService via Router.
    public init(
        stations: [JourneyStation],
        isReminderActive: Bool = true
    ) {
        self.stations = stations
        self.isReminderActive = isReminderActive
        self.trackingViewModel = JourneyTrackingVM()

        // Set activeStationIndex ke stasiun yang saat ini .current
        if let currentIdx = stations.firstIndex(where: { $0.type == .current }) {
            self.activeStationIndex = currentIdx
        }
    }

    // MARK: - Computed Properties

    public var currentStationIndex: Int {
        activeStationIndex
    }

    public var currentStation: JourneyStation? {
        guard stations.indices.contains(activeStationIndex) else { return nil }
        return stations[activeStationIndex]
    }

    public var currentStationName: String {
        currentStation?.name ?? "-"
    }

    public var nextStation: JourneyStation? {
        let nextIndex = activeStationIndex + 1
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
        return max(0, total - activeStationIndex)
    }

    // MARK: - Navigation / Actions

    public func makeDetailViewModel() -> JourneyPageDetailVM {
        JourneyPageDetailVM(stations: stations)
    }

    public func stopJourneyTracking() {
        trackingViewModel.locationManager.onLocationUpdate = nil
        trackingViewModel.stopTracking()
    }

    // MARK: - Tracking Control

    public func startTrackingIfPossible(modelContext: ModelContext) async {
        guard !isTrackingStarted,
              isReminderActive,
              let departure = stationDTO(named: currentStationName),
              let destination = stationDTO(named: destinationName) else { return }

        // Ask alarm permissions
        await trackingViewModel.alarmScheduler.requestAuthorizationIfNeeded()

        isTrackingStarted = true

        // Hubungkan callback real-time location update dari LocationManager
        trackingViewModel.locationManager.onLocationUpdate = { [weak self] location in
            Task { @MainActor in
                self?.updateStationProgress(with: location)
            }
        }

        await trackingViewModel.startTracking(
            departureStation: departure,
            destinationStation: destination,
            modelContext: modelContext
        )

        // Segera evaluasi posisi lokasi saat ini jika sudah ada
        if let currentLocation = trackingViewModel.locationManager.userLocation {
            updateStationProgress(with: currentLocation)
        }
    }

    // MARK: - Real-Time Segment & Station Tracking

    /// Menghitung progres posisi user di sepanjang rute stasiun secara real-time.
    /// Mendukung baik saat user berada di area stasiun maupun saat bergerak di antara 2 stasiun.
    public func updateStationProgress(with userLocation: CLLocation) {
        guard stations.count >= 2 else { return }
        guard activeStationIndex < stations.count - 1 else { return } // Sudah di stasiun akhir

        let userLat = userLocation.coordinate.latitude
        let userLon = userLocation.coordinate.longitude

        // 1. Cek apakah user berada di dalam radius stasiun di depan (proximity check)
        for i in (activeStationIndex + 1)..<stations.count {
            let stationLoc = CLLocation(latitude: stations[i].latitude, longitude: stations[i].longitude)
            if userLocation.distance(from: stationLoc) <= stationProximityRadius {
                advanceToStation(index: i)
                return
            }
        }

        // 2. Jika di antara stasiun, temukan segmen rute (S_i -> S_i+1) terdekat dari lokasi user
        var bestSegmentIndex = activeStationIndex
        var minDistanceToSegment: CLLocationDistance = .infinity
        var bestSegmentT: Double = 0.0

        for i in 0..<(stations.count - 1) {
            let s1 = stations[i]
            let s2 = stations[i + 1]

            // Vektor S1 -> S2
            let dx = s2.latitude - s1.latitude
            let dy = s2.longitude - s1.longitude
            let lenSq = dx * dx + dy * dy

            var t = 0.0
            if lenSq > 0 {
                // Vektor S1 -> User
                let ux = userLat - s1.latitude
                let uy = userLon - s1.longitude
                t = (ux * dx + uy * dy) / lenSq
            }

            let tClamped = max(0.0, min(1.0, t))
            let projectedLat = s1.latitude + tClamped * dx
            let projectedLon = s1.longitude + tClamped * dy

            let projectedLoc = CLLocation(latitude: projectedLat, longitude: projectedLon)
            let distance = userLocation.distance(from: projectedLoc)

            if distance < minDistanceToSegment {
                minDistanceToSegment = distance
                bestSegmentIndex = i
                bestSegmentT = t
            }
        }

        // 3. Tentukan stasiun berdasarkan proyeksi segmen:
        // Jika t >= 0.8 (sudah sangat mendekati stasiun berikutnya), anggap sudah tiba di stasiun i + 1.
        // Jika t < 0.8 (sedang melaju di antara S_i dan S_i+1), current station adalah S_i dan next station adalah S_i+1.
        var detectedIndex = bestSegmentIndex
        if bestSegmentT >= 0.8 && (bestSegmentIndex + 1) < stations.count {
            detectedIndex = bestSegmentIndex + 1
        }

        // Kereta hanya bergerak maju (tidak pernah mundur ke stasiun sebelumnya)
        if detectedIndex > activeStationIndex {
            advanceToStation(index: detectedIndex)
        }
    }

    /// Meng-advance urutan stasiun:
    /// Stasiun sebelum index baru -> .past
    /// Stasiun pada index baru -> .current
    /// Stasiun setelahnya -> .next (terakhir tetap .destination)
    private func advanceToStation(index newIndex: Int) {
        guard newIndex > activeStationIndex else { return }

        for i in 0..<newIndex {
            stations[i].type = .past
        }
        stations[newIndex].type = (newIndex == stations.count - 1) ? .destination : .current
        for i in (newIndex + 1)..<stations.count {
            if i == stations.count - 1 {
                stations[i].type = .destination
            } else {
                stations[i].type = .next
            }
        }
        activeStationIndex = newIndex
    }

    private func stationDTO(named name: String) -> StationModelDTO? {
        StationModelDTO.loadFromJSON().first {
            $0.name.caseInsensitiveCompare(name) == .orderedSame
        }
    }
    
}
