//
//  HomeVM.swift
//  SampaiTitik
//
//  Created by Salman on 24/08/26.
//

internal import Combine
import Observation

@Observable
class HomeViewModel {
    /// Stasiun asal yang dipilih user
    var departStation: StationModelDTO? = nil
    /// Stasiun tujuan yang dipilih user
    var destStation: StationModelDTO? = nil

    var showDeparture: Bool = false
    var showDestination: Bool = false
    var isRotating: Bool = false

    /// Semua stasiun yang tersedia, dimuat sekali dari JSON saat init
    let allStations: [StationModelDTO]

    init() {
        self.allStations = StationModelDTO.loadFromJSON()
    }

    func swapStations() {
        (departStation, destStation) = (destStation, departStation)
        isRotating.toggle()
    }

    /// Apakah user sudah memilih kedua stasiun
    var isReadyToProceed: Bool {
        departStation != nil && destStation != nil
    }
}
