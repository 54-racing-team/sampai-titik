//
//  DestinationControlCardView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 23/08/26.
//

import SwiftUI

struct DestinationControlCardView: View {
    @Bindable var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 12) {
            if let _ = locationManager.destinationCoordinate ?? locationManager.selectedCoordinate {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Jarak ke Tujuan")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if let distance = locationManager.distanceToDestination {
                            Text(distance >= 1000 ? String(format: "%.1f km", distance / 1000.0) : String(format: "%.0f meter", distance))
                                .font(.title2.bold())
                                .foregroundColor(locationManager.isWithinTargetRadius ? .red : .primary)
                        } else {
                            Text("-")
                                .font(.title2.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "tram.fill")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text("ETA")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let durationText = locationManager.formattedEstimatedDuration {
                            Text(durationText)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        } else {
                            Text("-")
                                .font(.title2.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if locationManager.destinationCoordinate != nil {
                        Spacer()
                        
                        Button(action: {
                            locationManager.clearDestination()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Radius Alarm:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(locationManager.targetRadius)) meter")
                            .font(.caption.bold())
                    }
                    Slider(value: $locationManager.targetRadius, in: 50...1000, step: 25)
                }
                
                if locationManager.destinationCoordinate == nil {
                    Button(action: {
                        locationManager.saveDestination()
                    }) {
                        Label("Simpan tujuan", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 4)
                }
            } else {
                // Tampilan awal saat belum mengetuk peta
                HStack{
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(.blue)
                    Text("Ketuk titik di peta untuk menentukan lokasi tujuan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}
