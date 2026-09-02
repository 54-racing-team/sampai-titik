//
//  SearchStationView.swift
//  SampaiTitik
//
//  Created by Salman on 23/08/26.
//

import SwiftUI

struct SearchStationView: View {
    let stations: [StationModelDTO]
    @Binding var selectedStation: StationModelDTO?
    @Binding var isPresented: Bool

    @State var searchStation: String = ""

    var filteredStations: [StationModelDTO] {
        let list = searchStation.isEmpty ? stations : stations.filter { station in
            station.name.localizedStandardContains(searchStation)
        }
        return list.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    var body: some View {
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
    SearchStationView(
        stations: StationModelDTO.loadFromJSON(),
        selectedStation: .constant(nil),
        isPresented: .constant(false)
    )
}
