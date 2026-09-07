//
//  WatchModel.swift
//  SampaiTitik
//
//  Created by Salman on 02/09/26.
//

import Foundation

struct recentJourney: Codable, Hashable {
    let date: Date
    let origin: String
    let destination: String
}

struct setAlarm: Codable {
    let isAlarmOn: Bool
}

struct startJourney: Codable {
    let selectedJourney: recentJourney
    let alarmConfig: setAlarm
}

struct journeyTracking: Codable {
    let destination: String
    let currentStation: String
    let nextStation: String
    let stationRemaining: Int
}
