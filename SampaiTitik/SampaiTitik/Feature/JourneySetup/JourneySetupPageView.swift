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
    var initialSoundName: String?
    var initialTargetRadius: Double?

    @State private var locationManager = LocationManager.shared
    @State private var journeyRoute: JourneyRoute?
    @Environment(Router.self) private var router
    
    @State private var soundName: SoundOption

    private let routeService = JourneyRouteService(stations: StationModelDTO.loadFromJSON())

    init(
        departure: StationModelDTO,
        destination: StationModelDTO,
        soundName: String? = nil,
        targetRadius: Double? = nil
    ) {
        self.departure = departure
        self.destination = destination
        self.initialSoundName = soundName
        self.initialTargetRadius = targetRadius

        if let soundName, let option = SoundOption(rawValue: soundName) {
            self._soundName = State(initialValue: option)
        } else {
            self._soundName = State(initialValue: .heartOfHope)
        }
    }

    var body: some View {
        ZStack {
            Color.backgroundBlue
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    EstimateCard(
                        departureStation: departure,
                        destinationStation: destination,
                        estimatedDuration: journeyRoute?.estimatedDuration
                    )
                    
                    AlarmToogleCard(soundName: $soundName)

                    MapCard(
                        locationManager: locationManager,
                        departureStation: departure,
                        destinationStation: destination
                    )
                }
                .padding()
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
                            return JourneyStation(name: station.name, type: type, latitude: station.latitude, longitude: station.longitude)
                        }
                        router.push(
                            .confirmation(
                                stations: stations,
                                soundName: soundName.fileName,
                                targetRadius: locationManager.targetRadius
                            )
                        )
                    } label: {
                        Text("Mulai Perjalanan")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.mainBlue)
                    .padding(.horizontal)
                    .disabled(journeyRoute == nil)
                }
                .onAppear {
                    setupJourney()
                }
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
        // Atur radius: jika dari recent journey gunakan saved radius, jika perjalanan baru selalu reset ke default 500m
        if let initialRadius = initialTargetRadius {
            locationManager.targetRadius = initialRadius
        } else {
            locationManager.targetRadius = 500
        }
        // Hitung route sekali saat setup
        journeyRoute = routeService.createRoute(from: departure, to: destination)
    }
}

#Preview {
    let stations = StationModelDTO.loadFromJSON()
    let dep = stations.first { $0.id == "SUD" } ?? stations[0]
    let dst = stations.first { $0.id == "BKS" } ?? stations[1]
    NavigationStack {
        JourneySetupPageView(departure: dep, destination: dst)
            .environment(Router())
            .environment(WatchManager())
    }
}
