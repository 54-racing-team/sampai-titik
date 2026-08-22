//
//  MapView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 23/08/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        ZStack(alignment: .bottom) {
            MapReader { mapProxy in
                Map(position: $cameraPosition) {
                    UserAnnotation()

                    if let activeCoordinate = locationManager.selectedCoordinate ?? locationManager.destinationCoordinate {
                        Marker("Pilihan lokasi", coordinate: activeCoordinate)
                            .tint(.red)
                        MapCircle(center: activeCoordinate, radius: locationManager.targetRadius)
                            .foregroundStyle(Color.red.opacity(0.2))
                            .stroke(Color.red, lineWidth: 2)
                    }
                }
                .mapControls {
                    MapUserLocationButton() // Button untuk fokus kembali ke posisi user
                    MapCompass() // Button kompas
                }
                .onTapGesture { screenCoord in
                    if let coord = mapProxy.convert(screenCoord, from: .local) {
                        locationManager.selectDraftDestination(
                            coordinate: coord
                        )
                    }
                }
            }

            DestinationControlCardView(locationManager: locationManager)
        }
        .onAppear {
            locationManager.requestPermission()
        }
    }
}

#Preview {
    MapView()
}
