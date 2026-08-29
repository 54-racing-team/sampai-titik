//
//  JourneySetupPage.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 26/08/26.
//

import SwiftUI

struct JourneySetupPageView: View {
    @State private var locationManager = LocationManager()
    @Environment(Router.self) private var router
    
    private let journey = JourneySetupMockData.makeJourney()
    
    var body: some View {
        ZStack {
            Color.backgroundBlue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                AlarmToogleCard()
                
                MapCard(
                    locationManager: locationManager,
                    departureStation: journey.departureStation,
                    destinationStation: journey.destinationStation
                )
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .safeAreaInset(edge: .bottom) {
                Button {
                    router.push(.journeyPage)
                } label: {
                    Text("Mulai Perjalanan")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                }
                .buttonStyle(.glassProminent)
                .padding(.horizontal)
            }
            .onAppear {
                locationManager.setMockJourney(
                    departureStation: journey.departureStation,
                    destinationStation: journey.destinationStation
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Atur Perjalanan")
    }
}

enum JourneySetupMockData {
    static func makeJourney() -> (departureStation: StationModelDTO, destinationStation: StationModelDTO) {
        let stations = StationModelDTO.loadFromJSON()
        return (
            departureStation: station(withID: "SUD", in: stations),
            destinationStation: station(withID: "BKS", in: stations)
        )
    }
    
    private static func station(withID id: String, in stations: [StationModelDTO]) -> StationModelDTO {
        stations.first { $0.id == id } ?? fallbackStation
    }
    
    private static var fallbackStation: StationModelDTO {
        StationModelDTO(
            id: "MRI",
            name: "Manggarai",
            latitude: -6.2098,
            longitude: 106.8502,
            lines: [KRLLineDTO(line_name: "Bogor Line", order: 9)]
        )
    }
}

#Preview {
    JourneySetupPageView().environment(Router())
}
