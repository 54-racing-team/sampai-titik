//
//  StationViewModel.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

import Combine
import SwiftUI

class StationViewModel: ObservableObject {
    @Published var stations: [StationModel] = []
    
    func getStations() -> [StationModel] {
        guard let url = Bundle.main.url(forResource: "StationsData", withExtension: "json"), let data = try? Data(contentsOf: url) else {
            print("Error loading JSON path")
            return []
        }
        
        let decoder = JSONDecoder()
        guard let stations = try? decoder.decode([StationModel].self, from: data) else {
            print("Error parsing JSON file")
            return []
        }
        
        print(stations[0].id)
        self.stations = stations
        
        return stations
    }
}
