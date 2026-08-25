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
    
    public init(id: UUID = UUID(), name: String, type: StationType) {
        self.id = id
        self.name = name
        self.type = type
    }
}

// MARK: - Sample Data Helper
extension JourneyStation {
    public static let sampleStations: [JourneyStation] = [
        JourneyStation(name: "Sudirman", type: .past),
        JourneyStation(name: "Manggarai", type: .past),
        JourneyStation(name: "Tebet", type: .past),
        JourneyStation(name: "Cawang", type: .current),
        JourneyStation(name: "Duren Kalibata", type: .next),
        JourneyStation(name: "Pasar Minggu Baru", type: .next),
        JourneyStation(name: "Pasar Minggu", type: .next),
        JourneyStation(name: "Tanjung Barat", type: .next),
        JourneyStation(name: "Lenteng Agung", type: .next),
        JourneyStation(name: "Citayem", type: .next),
        JourneyStation(name: "Bojong Gede", type: .destination)
    ]
}
