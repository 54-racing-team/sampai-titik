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
        var remainingStation:String
    }
}

extension LiveActivityAttributes {
    static var preview: LiveActivityAttributes {
        .init(appTitle: "SampaiTitik",
              journeyCaption: "Journey",
              startStation: "Jakarta",
              endStation: "Surabaya",
              id: .init())
    }
}
