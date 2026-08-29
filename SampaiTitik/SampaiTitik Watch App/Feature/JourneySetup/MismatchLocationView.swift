//
//  MismatchLocationView.swift
//  SampaiTitik Watch App
//
//  Created by Muhammad Muthi' Nuritzan on 29/08/26.
//

import SwiftUI

struct MismatchLocationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Anda terdeketsi di Stasiun Pondok Ranji. Ingin mengubah lokasi")
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(spacing: 8) {
                    NavigationLink{
                        // Action
                    } label: {
                        Text("Ya")
                            .font(.caption)
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
    MismatchLocationView()
}
