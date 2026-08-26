//
//  StationModel.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

import Foundation
import SwiftData

@Model
final class StationModel {
    @Attribute(.unique) var id: String
    var name : String
    var latitude : Double
    var longitude: Double
    var lines : [KRLLine]
    
    init(id: String, name: String, latitude: Double, longitude: Double, lines: [KRLLine]) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.lines = lines
    }
    
    init(from dto: StationModelDTO) {
        self.id = dto.id
        self.name = dto.name
        self.latitude = dto.latitude
        self.longitude = dto.longitude
        self.lines = dto.lines.map { line in return KRLLine(line_name: line.line_name, order: line.order)}
    }
}

struct KRLLine: Codable {
    var line_name: String
    var order: Int
}
