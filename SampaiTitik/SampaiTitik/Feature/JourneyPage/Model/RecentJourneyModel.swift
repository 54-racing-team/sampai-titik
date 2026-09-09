//
//  RecentJourneyModel.swift
//  SampaiTitik
//
//  Created by Salman on 03/09/26.
//

import SwiftData
import Foundation

@Model
class RecentJourneyModel {
    var date: Date
    var origin: String
    var destination: String
    var soundName: String?
    var targetRadius: Double?
    
    init(
        date: Date,
        origin: String,
        destination: String,
        soundName: String? = nil,
        targetRadius: Double? = 500
    ) {
        self.date = date
        self.origin = origin
        self.destination = destination
        self.soundName = soundName
        self.targetRadius = targetRadius ?? 500
    }
}
