//
//  StationModel.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

import Combine
import MapKit

struct KRLLine: Codable {
    let line_name: String
    let order: Int
}

struct StationModel: Identifiable, Codable {
    let id: String
    let name : String
    let latitude : Double
    let longitude: Double
    let lines : [KRLLine]
}

