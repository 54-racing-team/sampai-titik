//
//  DetailJourneyView.swift
//  SampaiTitik Watch App
//
//  Created by Muhammad Muthi' Nuritzan on 29/08/26.
//

import SwiftUI

struct InformationJourneyPage: View {
    @Environment(Router.self) var route

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Tujuan Akhir")
                    .font(.title3.bold())
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack{
                    Image(systemName: "location.fill")
                        .font(.caption)
                    
                    Text("Metland Telaga Murni")
                        .font(.caption)
                        .foregroundStyle(.mainBlue)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .glassEffect(.regular, in: Capsule())
                
                
                HStack(spacing: 8) {
                    Text("13")
                        .font(.title3.bold())
                        .foregroundStyle(.orange)
                    
                    Text("sisa pemberhentian")
                        .font(.caption)
                }
                .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stasiun berikutnya")
                        .font(.headline)
                    
                    HStack{
                        Image(systemName: "tram.fill")
                            .font(.caption)
                        
                        Text("Klender Baru")
                            .font(.caption)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}

#Preview {
    InformationJourneyPage()
        .environment(Router())
}
