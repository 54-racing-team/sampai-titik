//
//  JourneyPageModel.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import Foundation

public enum StationType: String, Codable, CaseIterable, Equatable, Hashable {
    case past
    case current
    case next
    case destination
}

public struct JourneyStation: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var type: StationType
    public var latitude: Double
    public var longitude: Double
    
    public init(id: UUID = UUID(), name: String, type: StationType, latitude: Double = 0, longitude: Double = 0) {
        self.id = id
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Sample Data Helper
extension JourneyStation {
    public static let sampleStations: [JourneyStation] = [
        JourneyStation(name: "Sudirman", type: .past, latitude: -6.2025, longitude: 106.8236),
        JourneyStation(name: "Manggarai", type: .past, latitude: -6.2098, longitude: 106.8502),
        JourneyStation(name: "Tebet", type: .past, latitude: -6.2263, longitude: 106.8583),
        JourneyStation(name: "Cawang", type: .current, latitude: -6.2425, longitude: 106.8582),
        JourneyStation(name: "Duren Kalibata", type: .next, latitude: -6.2555, longitude: 106.855),
        JourneyStation(name: "Pasar Minggu Baru", type: .next, latitude: -6.2628, longitude: 106.85),
        JourneyStation(name: "Pasar Minggu", type: .next, latitude: -6.2839, longitude: 106.8439),
        JourneyStation(name: "Tanjung Barat", type: .next, latitude: -6.3075, longitude: 106.8386),
        JourneyStation(name: "Lenteng Agung", type: .next, latitude: -6.3308, longitude: 106.8344),
        JourneyStation(name: "Citayam", type: .next, latitude: -6.4489, longitude: 106.8061),
        JourneyStation(name: "Bojong Gede", type: .destination, latitude: -6.4932, longitude: 106.795)
    ]
}
