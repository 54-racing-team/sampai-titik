//
//  HomeModel.swift
//  SampaiTitik
//
//  Created by Salman on 27/08/26.
//

import SwiftData

@Model
class HomeModel {
    var destination: String
    var departure: String
    
    init(destination: String, departure: String) {
        self.destination = destination
        self.departure = departure
    }
}
