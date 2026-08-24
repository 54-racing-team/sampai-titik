//
//  StationSelectionViewModel.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

import Combine

class StationSelectionViewModel: ObservableObject {
    @Published var departStation: String = ""
    @Published var destStation: String = ""
    @Published var showDeparture: Bool = false
    @Published var showDestination: Bool = false
    @Published var isRotating: Bool = false
    
    func swapStations(){
        (departStation, destStation) = (destStation, departStation)
        isRotating.toggle()
    }
}
