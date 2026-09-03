//
//  SearchStationView.swift
//  SampaiTitik
//
//  Created by Salman on 23/08/26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct SearchStationView: View {
    let stations: [StationModelDTO]
    @Binding var selectedStation: StationModelDTO?
    @Binding var isPresented: Bool
    var showNearestStation: Bool = false
    var maxDistanceMeters: CLLocationDistance = 10_000
    
    @State var searchStation: String = ""
    private var locationManager: LocationManager { LocationManager.shared }
    private var hasUserLocation: Bool {
        locationManager.userLocation != nil
    }
    
    var nearestStations: [(station: StationModelDTO, distance: CLLocationDistance)] {
        guard let userLoc = locationManager.userLocation else { return [] }
        let mapped = stations.map { station -> (station: StationModelDTO, distance: CLLocationDistance) in
            let loc = CLLocation(latitude: station.latitude, longitude: station.longitude)
            let dist = userLoc.distance(from: loc)
            return (station: station, distance: dist)
        }
        let withinRange = mapped.filter { $0.distance <= maxDistanceMeters }
        let sorted = withinRange.sorted { $0.distance < $1.distance }
        return Array(sorted.prefix(3))
    }
    
    func formattedDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    var filteredStations: [StationModelDTO] {
        let list = searchStation.isEmpty ? stations : stations.filter { station in
            station.name.localizedStandardContains(searchStation) ||
            station.id.localizedStandardContains(searchStation)
        }
        return list.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if showNearestStation && searchStation.isEmpty {
                    if !nearestStations.isEmpty {
                        Section("Stasiun Terdekat") {
                            ForEach(nearestStations, id: \.station.id) { item in
                                Button {
                                    selectedStation = item.station
                                    isPresented = false
                                } label: {
                                    HStack(spacing: 12) {
//                                        Image(systemName: "location.fill")
//                                            .foregroundStyle(.mainBlue)
//                                            .font(.headline)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.station.name)
                                                .font(.body)
                                                .foregroundStyle(.primary)
                                            Text("Jarak: \(formattedDistance(item.distance))")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(item.station.id)
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    } else if !hasUserLocation {
                        Section("Stasiun Terdekat") {
                            HStack{
                                ProgressView()
                                Text("Mencari stasiun terdekat...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    Section("Semua Stasiun") {
                        stationRows(filteredStations)
                    }
                } else {
                    stationRows(filteredStations)
                }
                .foregroundStyle(.primary)
            }
            .searchable(text: $searchStation, prompt: "Cari stasiun...")
            .navigationTitle("Pilih Stasiun")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if showNearestStation {
                    locationManager.requestCurrentLocation()
                }
            }
        }
    }
    
    @ViewBuilder
    private func stationRows(_ list: [StationModelDTO]) -> some View {
        ForEach(list) { station in
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
    }
}

#Preview {
    SearchStationView(
        stations: StationModelDTO.loadFromJSON(),
        selectedStation: .constant(nil),
        isPresented: .constant(false),
        showNearestStation: true
    )
}
