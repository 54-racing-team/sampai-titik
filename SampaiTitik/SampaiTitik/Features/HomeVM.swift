//
//  StationSelectionViewModel.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

import Observation

@Observable
class HomeViewModel {
    var departStation: String = ""
    var destStation: String = ""
    var showDeparture: Bool = false
    var showDestination: Bool = false
    var isRotating: Bool = false
    
    func swapStations(){
        (departStation, destStation) = (destStation, departStation)
        isRotating.toggle()
    }
}
