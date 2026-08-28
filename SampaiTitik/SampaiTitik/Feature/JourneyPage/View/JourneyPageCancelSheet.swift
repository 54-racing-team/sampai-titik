//
//  JourneyPageCancelSheet.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 25/08/26.
//

import SwiftUI

struct JourneyPageCancelSheet: View {
    var onConfirm: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("CancelSheet")
            
            VStack(spacing: 6) {
                Text("Akhiri perjalanan lebih awal?")
                    .font(.headline)
                
                Text("Perjalananmu saat ini akan berhenti dan pengingat tidak akan aktif lagi")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Tidak jadi")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding(10)
                }
                .buttonStyle(.glassProminent)
                .tint(.secondary)
                
                Button {
                    // Cancel the trip
                } label: {
                    Text("Ya, akhiri")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding(10)
                }
                .buttonStyle(.glassProminent)
                .tint(.red)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding(.top, 12)
    }
}

#Preview {
    JourneyPageCancelSheet()
}
