//
//  SearchStationView.swift
//  SampaiTitik
//
//  Created by Salman on 23/08/26.
//

import SwiftUI
import SwiftData

<<<<<<< HEAD
struct SearchStationSheet: View {
    @Query var stations: [StationModel]
    
    @Binding var selectedStation: String
=======
struct SearchStationView: View {
    let stations: [StationModelDTO]
    @Binding var selectedStation: StationModelDTO?
>>>>>>> trial
    @Binding var isPresented: Bool

    @State var searchStation: String = ""
<<<<<<< HEAD
    
    var filteredStations: [StationModel] {
        if searchStation.isEmpty {
            stations
        } else {
            stations.filter { station in
                station.name.localizedStandardContains(searchStation)
            }
=======

    var filteredStations: [StationModelDTO] {
        let list = searchStation.isEmpty ? stations : stations.filter { station in
            station.name.localizedStandardContains(searchStation)
        }
        return list.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
>>>>>>> trial
        }
    }

    var body: some View {
<<<<<<< HEAD
        NavigationStack{
            VStack{
                List(filteredStations){ station in
                    Button{
                        selectedStation = station.name
                        isPresented.toggle()
                        
                    } label: {
                        HStack{
                            Text(station.name)
                            Spacer()
                            Text(station.id)
                        }
                        .foregroundColor(.black)
=======
        NavigationStack {
            List(filteredStations) { station in
                Button {
                    selectedStation = station
                    isPresented = false
                } label: {
                    HStack {
                        Text(station.name)
                        Spacer()
                        Text(station.id)
                            .foregroundStyle(.secondary)
                            .font(.caption)
>>>>>>> trial
                    }
                }
                .foregroundStyle(.primary)
            }
            .searchable(text: $searchStation, prompt: "Cari stasiun...")
            .navigationTitle("Pilih Stasiun")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
<<<<<<< HEAD
    SearchStationSheet(selectedStation: .constant(""), isPresented: .constant(false))
=======
    SearchStationView(
        stations: StationModelDTO.loadFromJSON(),
        selectedStation: .constant(nil),
        isPresented: .constant(false)
    )
>>>>>>> trial
}
