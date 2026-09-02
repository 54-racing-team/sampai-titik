//
//  MapCard.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 23/08/26.
//

import SwiftUI
import MapKit

struct MapCard: View {
    @Bindable var locationManager: LocationManager
    var departureStation: StationModelDTO?
    var destinationStation: StationModelDTO?
    /// Estimasi durasi perjalanan (dalam detik) dari JourneyRouteService.
    /// Bila nil, ditampilkan sebagai "--".
    var estimatedDuration: TimeInterval?
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var hasInitializedCamera: Bool = false
    
    init(
        locationManager: LocationManager,
        departureStation: StationModelDTO? = nil,
        destinationStation: StationModelDTO? = nil,
        estimatedDuration: TimeInterval? = nil
    ) {
        self.locationManager = locationManager
        self.departureStation = departureStation
        self.destinationStation = destinationStation
        self.estimatedDuration = estimatedDuration
    }
    
    init(
        departureStation: StationModelDTO? = nil,
        destinationStation: StationModelDTO? = nil,
        estimatedDuration: TimeInterval? = nil
    ) {
        self._locationManager = Bindable(wrappedValue: LocationManager.shared)
        self.departureStation = departureStation
        self.destinationStation = destinationStation
        self.estimatedDuration = estimatedDuration
    }
    
    private var activeStation: StationModelDTO? {
        destinationStation ?? locationManager.destinationStation
    }
    
    private var activeCoordinate: CLLocationCoordinate2D? {
        activeStation?.coordinate ?? locationManager.destinationCoordinate ?? locationManager.selectedCoordinate
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Map Section (Card Top)
            ZStack(alignment: .topTrailing) {
                Map(position: $cameraPosition) {
                    UserAnnotation()
                    
                    if let coord = activeCoordinate {
                        Marker(
                            activeStation?.name ?? "Stasiun Tujuan",
                            coordinate: coord
                        )
                        
                        MapCircle(center: coord, radius: locationManager.targetRadius)
                            .foregroundStyle(Color.red.opacity(0.2))
                            .stroke(Color.red, lineWidth: 1)
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .frame(height: 250)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 20,
                        style: .continuous
                    )
                )
                
                // Recenter / Focus Button
                Button {
                    focusOnDestination()
                } label: {
                    Image(systemName: "location.fill")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(9)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                }
                .padding(12)
            }
            
            // MARK: - Radius Adjustment Slider Section (Card Bottom)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Radius Alarm")
                    
                    Spacer()
                    
                    Text("\(Int(locationManager.targetRadius)) meter")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $locationManager.targetRadius, in: 50...1000, step: 25)
                    .tint(.mainBlue)
                
                HStack {
                    Text("50 m")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("500 m")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1000 m")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color.backgroundCard)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 0,
                    style: .continuous
                )
            )
        }
        .glassEffect(in: .rect(cornerRadius: 20))
        .onAppear {
            locationManager.requestPermission()
            setupDestination()
        }
        .onChange(of: destinationStation?.id) { _, _ in
            if let destinationStation {
                locationManager.setDestination(station: destinationStation)
                focusOnDestination()
            }
        }
    }
    
    private func setupDestination() {
        if let destinationStation {
            locationManager.setDestination(station: destinationStation)
        }
        if !hasInitializedCamera {
            focusOnDestination()
            hasInitializedCamera = true
        }
    }
    
    private func focusOnDestination() {
        guard let coord = activeCoordinate else { return }
        let spanMeters = max(locationManager.targetRadius * 3.5, 1200)
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coord,
                    latitudinalMeters: spanMeters,
                    longitudinalMeters: spanMeters
                )
            )
        }
    }
}

#Preview {
    let stations = StationModelDTO.loadFromJSON()
    let dep = stations.first { $0.id == "SUD" } ?? stations[0]
    let dst = stations.first { $0.id == "BKS" } ?? stations[1]
    let locationManager = LocationManager()
    locationManager.setMockJourney(departureStation: dep, destinationStation: dst)
    let route = JourneyRouteService(stations: stations).createRoute(from: dep, to: dst)
    
    return ScrollView {
        VStack(spacing: 20) {
            MapCard(
                locationManager: locationManager,
                departureStation: dep,
                destinationStation: dst,
                estimatedDuration: route?.estimatedDuration
            )
        }
        .padding()
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
