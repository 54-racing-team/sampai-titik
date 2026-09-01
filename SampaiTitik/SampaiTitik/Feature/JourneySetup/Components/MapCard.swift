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

    private var formattedDuration: String {
        guard let duration = estimatedDuration else { return "-- menit" }
        let minutes = Int(ceil(duration / 60.0))
        if minutes < 1 {
            return "< 1 menit"
        } else if minutes >= 60 {
            let hours = minutes / 60
            let remaining = minutes % 60
            return remaining == 0 ? "\(hours) jam" : "\(hours) jam \(remaining) menit"
        } else {
            return "\(minutes) menit"
        }
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

            // MARK: - Route Indicator & Slider Section (Card Bottom)
            VStack(alignment: .leading, spacing: 14) {
                VStack(spacing: 4) {
                    Text(formattedDuration)
                        .font(.caption2)
                        .multilineTextAlignment(.center)

                    routeIndicator

                    HStack(alignment: .top, spacing: 0) {
                        VStack(spacing: 4) {
                            Text(departureStation?.name ?? "Stasiun Asal")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(width: 80)

                        Spacer()

                        Text(activeStation?.name ?? "Stasiun Tujuan")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: 80)
                    }
                }

                Divider()

                // Radius Adjustment Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Radius Alarm")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(Int(locationManager.targetRadius)) meter")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Slider(value: $locationManager.targetRadius, in: 50...1000, step: 25)
                        .tint(.blue)

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
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
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

    private var routeIndicator: some View {
        GeometryReader { proxy in
            let markerWidth: CGFloat = 80
            let markerRadius: CGFloat = 9
            let centerY = proxy.size.height / 2

            Path { path in
                path.move(to: CGPoint(x: markerWidth / 2 + markerRadius, y: centerY))
                path.addLine(to: CGPoint(x: proxy.size.width - markerWidth / 2 - markerRadius, y: centerY))
            }
            .stroke(
                Color.gray.opacity(0.5),
                style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
            )

            HStack(spacing: 0) {
                stationMarker(color: .black)
                    .frame(width: markerWidth)

                Spacer(minLength: 0)

                stationMarker(color: .blue)
                    .frame(width: markerWidth)
            }
        }
        .frame(height: 18)
    }

    private func stationMarker(color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 18, height: 18)
            Circle()
                .fill(.white)
                .frame(width: 6, height: 6)
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
