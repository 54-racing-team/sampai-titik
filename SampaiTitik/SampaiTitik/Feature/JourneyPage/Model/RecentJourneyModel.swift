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
    
    init(date: Date, origin: String, destination: String) {
        self.date = date
        self.origin = origin
        self.destination = destination
    }
}
