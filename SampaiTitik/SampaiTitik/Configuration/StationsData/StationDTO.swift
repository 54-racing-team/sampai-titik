//
//  StationDTO.swift
//  SampaiTitik
//
//  Created by Salman on 26/08/26.
//

import Foundation

struct StationsDTO: Codable {
    var data_version: Int
    var stations: [StationModelDTO]
}

struct StationModelDTO: Identifiable, Codable, Hashable, Equatable {
    var id: String
    let name : String
    let latitude : Double
    let longitude: Double
    let lines : [KRLLineDTO]
}

struct KRLLineDTO: Codable, Hashable, Equatable {
    let line_name: String
    let order: Int
}
