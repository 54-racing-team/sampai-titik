//
//  StationViewModel.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

import Combine
import SwiftUI
import SwiftData

class StationViewModel: ObservableObject {
    @Published var stations: [StationModelDTO] = []
    
    func getStations(context: ModelContext) {
        let descriptor = FetchDescriptor<StationModel>()
        let existingCount = try? context.fetchCount(descriptor)
        
        if existingCount != 0 {
            return
        }
        
        guard let url = Bundle.main.url(forResource: "StationsData", withExtension: "json"), let data = try? Data(contentsOf: url) else {
            print("Error loading JSON path")
            return
        }
        
        let decoder = JSONDecoder()
        guard let stations = try? decoder.decode(StationsDTO.self, from: data) else {
            print("Error parsing JSON file")
            return
        }
        
        for station in stations.stations {
            let stationModel = StationModel(from: station)
            context.insert(stationModel)
        }
        
        guard let save = try? context.save() else {
            print("Error saving data")
            return
        }
        print("Data saved")
    }
}
