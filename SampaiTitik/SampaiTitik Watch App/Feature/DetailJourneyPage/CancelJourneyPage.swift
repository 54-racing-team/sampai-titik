//
//  CancelJourneyView.swift
//  SampaiTitik Watch App
//
//  Created by Muhammad Muthi' Nuritzan on 30/08/26.
//

import SwiftUI

struct CancelJourneyPage: View {
    @State private var isCancelJourney: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Batalkan Perjalanan?")
                .font(.title3)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Button{
                isCancelJourney = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $isCancelJourney) {
            CancelJourneyPopUp()
        }
    }
}

#Preview {
    CancelJourneyPage()
}
