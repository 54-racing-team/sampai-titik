//
//  JourneyRouteService.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 30/08/26.
//

import Foundation
import CoreLocation

// MARK: - JourneyRoute

/// Hasil kalkulasi route dari departure ke destination.
/// Berisi urutan stasiun yang dilalui dan estimasi total durasi perjalanan.
struct JourneyRoute {
    /// Urutan stasiun dari departure hingga destination (inklusif).
    let stations: [StationModelDTO]
    /// Estimasi total durasi perjalanan dalam detik.
    let estimatedDuration: TimeInterval

    var formattedEstimatedDuration: String {
        let minutes = Int(ceil(estimatedDuration / 60.0))
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
}

// MARK: - JourneyRouteService

/// Service yang bertanggung jawab untuk:
/// - Membangun graph stasiun KRL dari data lokal
/// - Mencari urutan stasiun (BFS) dari departure ke destination
/// - Menghitung estimasi durasi (Dijkstra) berdasarkan jarak antar-stasiun
///
/// Tidak bergantung pada CLLocationManager, UI, alarm, atau networking.
final class JourneyRouteService {
    private let stations: [StationModelDTO]

    /// Kecepatan rata-rata KRL dalam meter per detik (~40 km/jam)
    private let averageSpeedMPS: Double = 40.0 * 1000.0 / 3600.0
    /// Waktu berhenti di setiap stasiun dalam detik
    private let stationStopAllowance: TimeInterval = 45

    init(stations: [StationModelDTO]) {
        self.stations = stations
    }

    // MARK: - Public API

    /// Membuat route dari departure ke destination.
    /// - Returns: `JourneyRoute` berisi urutan stasiun dan estimasi durasi, atau `nil` jika tidak ada path.
    func createRoute(from departure: StationModelDTO, to destination: StationModelDTO) -> JourneyRoute? {
        guard departure.id != destination.id else {
            return JourneyRoute(stations: [departure], estimatedDuration: 0)
        }

        let stationsByID = Dictionary(uniqueKeysWithValues: stations.map { ($0.id, $0) })
        guard stationsByID[departure.id] != nil, stationsByID[destination.id] != nil else {
            return nil
        }

        let weightedGraph = buildWeightedGraph()

        guard let result = findShortestRoute(
            from: departure.id,
            to: destination.id,
            in: weightedGraph
        ) else {
            return nil
        }

        let orderedStations = result.path.compactMap { stationsByID[$0] }
        guard !orderedStations.isEmpty else { return nil }

        return JourneyRoute(stations: orderedStations, estimatedDuration: result.duration)
    }

    // MARK: - Graph Building

    /// Membangun weighted graph: edge berisi durasi perjalanan antar-stasiun.
    private func buildWeightedGraph() -> [String: [(stationID: String, duration: TimeInterval)]] {
        var graph: [String: [(stationID: String, duration: TimeInterval)]] = [:]
        let lineNames = Set(stations.flatMap { $0.lines.map(\.line_name) })

        for lineName in lineNames {
            let ordered = stationsOrderedOnLine(lineName)
            for pair in zip(ordered, ordered.dropFirst()) {
                let duration = travelDuration(between: pair.0.station, and: pair.1.station)
                graph[pair.0.station.id, default: []].append((pair.1.station.id, duration))
                graph[pair.1.station.id, default: []].append((pair.0.station.id, duration))
            }
        }

        return graph
    }

    private func stationsOrderedOnLine(_ lineName: String) -> [(station: StationModelDTO, order: Int)] {
        stations.flatMap { station in
            station.lines
                .filter { $0.line_name == lineName }
                .map { (station: station, order: $0.order) }
        }
        .sorted { $0.order < $1.order }
    }

    // MARK: - Path Finding

    /// Dijkstra untuk mencari urutan stasiun dan estimasi durasi terpendek dari departure ke destination.
    private func findShortestRoute(
        from departureID: String,
        to destinationID: String,
        in graph: [String: [(stationID: String, duration: TimeInterval)]]
    ) -> (path: [String], duration: TimeInterval)? {
        var bestDurations: [String: TimeInterval] = [departureID: 0]
        var previousID: [String: String] = [:]
        var visited = Set<String>()

        while true {
            guard let currentID = bestDurations
                .filter({ !visited.contains($0.key) })
                .min(by: { $0.value < $1.value })?
                .key,
                let currentDuration = bestDurations[currentID] else {
                break
            }

            if currentID == destinationID {
                var path = [destinationID]
                var curr = destinationID
                while let prev = previousID[curr] {
                    path.append(prev)
                    curr = prev
                }
                return (path.reversed(), currentDuration)
            }

            visited.insert(currentID)

            for edge in graph[currentID, default: []] where !visited.contains(edge.stationID) {
                let candidate = currentDuration + edge.duration
                if candidate < (bestDurations[edge.stationID] ?? .infinity) {
                    bestDurations[edge.stationID] = candidate
                    previousID[edge.stationID] = currentID
                }
            }
        }

        return nil
    }

    // MARK: - Duration Helpers

    private func travelDuration(between first: StationModelDTO, and second: StationModelDTO) -> TimeInterval {
        let firstLocation = CLLocation(latitude: first.latitude, longitude: first.longitude)
        let secondLocation = CLLocation(latitude: second.latitude, longitude: second.longitude)
        let distance = firstLocation.distance(from: secondLocation)
        return distance / averageSpeedMPS + stationStopAllowance
    }
}
