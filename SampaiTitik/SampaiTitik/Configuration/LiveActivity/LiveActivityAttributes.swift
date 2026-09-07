//
//  LiveActivityAttribtues.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 27/08/26.
//

import Foundation
import ActivityKit

struct LiveActivityAttributes: ActivityAttributes {
    
    var appTitle: String
    var journeyCaption: String
    var startStation: String
    var endStation: String
    var id: UUID
    
    public struct ContentState: Codable, Hashable {
        var isOnJourney: Bool
        var currentStation: String
        var remainingTime: String
        var remainingStation: String
        
        var currentStationCode: String?
        var currentStationName: String?
        var nextStationCode: String?
        var nextStationName: String?
        var isMuted: Bool?
        var isSoundEnabled: Bool?
        
        var displayCurrentCode: String {
            currentStationCode ?? (currentStation.isEmpty ? "SUD" : currentStation)
        }
        
        var displayCurrentName: String {
            currentStationName ?? "Sudirman"
        }
        
        var displayNextCode: String {
            nextStationCode ?? (remainingStation.isEmpty ? "MRI" : remainingStation)
        }
        
        var displayNextName: String {
            nextStationName ?? "Manggarai"
        }
        
        var displayIsMuted: Bool {
            isMuted ?? false
        }
        
        var displayIsSoundEnabled: Bool {
            isSoundEnabled ?? !displayIsMuted
        }
    }
}

extension LiveActivityAttributes {
    static var preview: LiveActivityAttributes {
        .init(appTitle: "SampaiTitik",
              journeyCaption: "Journey",
              startStation: "Sudirman",
              endStation: "Manggarai",
              id: .init())
    }
}
