//
//  CancelJourneyPopUp.swift
//  SampaiTitik Watch App
//
//  Created by Muhammad Muthi' Nuritzan on 30/08/26.
//

import SwiftUI

struct CancelJourneyPopUp: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Perjalananmu saat ini akan berhenti dan pengingat tidak akan aktif lagi.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 8) {
                    Button{
                        // Action
                    } label: {
                        Text("Ya, batalkan")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.glass)
                    
                    Button{
                        dismiss()
                    } label: {
                        Text("Tidak")
                            .font(.caption)
                    }
                    .buttonStyle(.glass)
                }
                
            }
        }
    }
}

#Preview {
    CancelJourneyPopUp()
}
