//
//  JourneySetupPage.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 26/08/26.
//

import SwiftUI

struct JourneySetupPageView: View {
    let departure: StationModelDTO
    let destination: StationModelDTO

    @State private var locationManager = LocationManager.shared
    @State private var journeyRoute: JourneyRoute?
    @Environment(Router.self) private var router

    private let routeService = JourneyRouteService(stations: StationModelDTO.loadFromJSON())

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack(spacing: 20) {
                AlarmToogleCard()

                MapCard(
                    locationManager: locationManager,
                    departureStation: departure,
                    destinationStation: destination,
                    estimatedDuration: journeyRoute?.estimatedDuration
                )

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .safeAreaInset(edge: .bottom) {
                Button {
                    guard let route = journeyRoute else { return }
                    let stations = route.stations.enumerated().map { index, station -> JourneyStation in
                        let type: StationType
                        if index == 0 {
                            type = .current
                        } else if index == route.stations.count - 1 {
                            type = .destination
                        } else {
                            type = .next
                        }
                        return JourneyStation(name: station.name, type: type)
                    }
                    router.push(.journeyPage(stations: stations))
                } label: {
                    Text("Mulai Perjalanan")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                }
                .buttonStyle(.glassProminent)
                .padding(.horizontal)
                .disabled(journeyRoute == nil)
            }
            .onAppear {
                setupJourney()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Atur Perjalanan")
    }

    private func setupJourney() {
        // Persiapkan map dengan posisi mock di departure station
        locationManager.setMockJourney(
            departureStation: departure,
            destinationStation: destination
        )
        // Hitung route sekali saat setup
        journeyRoute = routeService.createRoute(from: departure, to: destination)
    }
}

#Preview {
    let stations = StationModelDTO.loadFromJSON()
    let dep = stations.first { $0.id == "SUD" } ?? stations[0]
    let dst = stations.first { $0.id == "BKS" } ?? stations[1]
    return NavigationStack {
        JourneySetupPageView(departure: dep, destination: dst)
            .environment(Router())
    }
}
