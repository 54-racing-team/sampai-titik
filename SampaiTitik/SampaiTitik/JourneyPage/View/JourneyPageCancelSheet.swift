//
//  JourneyPageCancelSheet.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 25/08/26.
//

import SwiftUI

struct JourneyPageCancelSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Image("CancelSheet")
            
            VStack(spacing: 4) {
                Text("Akhiri perjalanan lebih awal?")
                    .font(.headline)
                
                Text("Perjalananmu saat ini akan berhenti dan pengingat tidak akan aktif lagi")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding()
            
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Tidak jadi")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.red)
                        .padding(10)
                }
                .buttonStyle(.glassProminent)
                .tint(.white)
                .overlay{
                    Capsule()
                        .stroke(.red, lineWidth: 1)
                }
                
                
                Button{
                    
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
            .padding()
        }
    }
}

#Preview {
    JourneyPageCancelSheet()
}
