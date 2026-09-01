//
//  ConfirmationSplash.swift
//  SampaiTitik Watch App
//
//  Created by Muhammad Muthi' Nuritzan on 29/08/26.
//

import SwiftUI

struct ConfirmationSplash: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Aplikasi akan mengingatkan kamu ketika mendekati Stasiun Metland Telaga Murni.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ConfirmationSplash()
}
