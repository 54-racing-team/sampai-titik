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
        let unweightedGraph = buildUnweightedGraph()

        // Urutan stasiun via BFS
        guard let orderedStationIDs = bfsPath(
            from: departure.id,
            to: destination.id,
            in: unweightedGraph
        ) else {
            return nil
        }

        // Durasi via Dijkstra
        guard let duration = dijkstraDuration(
            from: departure.id,
            to: destination.id,
            in: weightedGraph
        ) else {
            return nil
        }

        let orderedStations = orderedStationIDs.compactMap { stationsByID[$0] }
        guard !orderedStations.isEmpty else { return nil }

        return JourneyRoute(stations: orderedStations, estimatedDuration: duration)
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

    /// Membangun unweighted graph: edge hanya berisi adjacency (untuk BFS path finding).
    private func buildUnweightedGraph() -> [String: Set<String>] {
        var graph: [String: Set<String>] = [:]
        let lineNames = Set(stations.flatMap { $0.lines.map(\.line_name) })

        for lineName in lineNames {
            let ordered = stationsOrderedOnLine(lineName)
            for pair in zip(ordered, ordered.dropFirst()) {
                graph[pair.0.station.id, default: []].insert(pair.1.station.id)
                graph[pair.1.station.id, default: []].insert(pair.0.station.id)
            }
        }

        return graph
    }

    private func stationsOrderedOnLine(_ lineName: String) -> [(station: StationModelDTO, order: Int)] {
        stations
            .compactMap { station -> (station: StationModelDTO, order: Int)? in
                guard let line = station.lines.first(where: { $0.line_name == lineName }) else { return nil }
                return (station, line.order)
            }
            .sorted { $0.order < $1.order }
    }

    // MARK: - Path Finding

    /// BFS untuk mendapatkan urutan stasiun dari departure ke destination.
    private func bfsPath(
        from departureID: String,
        to destinationID: String,
        in graph: [String: Set<String>]
    ) -> [String]? {
        var queue = [departureID]
        var visited = Set([departureID])
        var previousID: [String: String] = [:]

        while !queue.isEmpty {
            let currentID = queue.removeFirst()
            if currentID == destinationID { break }

            for neighborID in graph[currentID, default: []].sorted() where !visited.contains(neighborID) {
                visited.insert(neighborID)
                previousID[neighborID] = currentID
                queue.append(neighborID)
            }
        }

        guard visited.contains(destinationID) else { return nil }

        var path = [destinationID]
        var current = destinationID
        while let previous = previousID[current] {
            path.append(previous)
            current = previous
        }

        return path.reversed()
    }

    /// Dijkstra untuk menghitung durasi terpendek dari departure ke destination.
    private func dijkstraDuration(
        from departureID: String,
        to destinationID: String,
        in graph: [String: [(stationID: String, duration: TimeInterval)]]
    ) -> TimeInterval? {
        var bestDurations: [String: TimeInterval] = [departureID: 0]
        var pending = Set(stations.map { $0.id })

        while !pending.isEmpty {
            guard let currentID = pending.min(by: {
                (bestDurations[$0] ?? .infinity) < (bestDurations[$1] ?? .infinity)
            }), let currentDuration = bestDurations[currentID] else {
                break
            }

            if currentID == destinationID {
                return currentDuration
            }

            pending.remove(currentID)

            for edge in graph[currentID, default: []] where pending.contains(edge.stationID) {
                let candidate = currentDuration + edge.duration
                if candidate < (bestDurations[edge.stationID] ?? .infinity) {
                    bestDurations[edge.stationID] = candidate
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
