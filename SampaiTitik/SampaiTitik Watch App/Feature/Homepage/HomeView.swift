//
//  HomeView.swift
//  SampaiTitik
//
//  Created by Salman on 30/08/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) var route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rute Terakhir")
                .font(.headline)
                .foregroundStyle(Color("MainBlue"))
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    RecentJourneyCard(
                        origin: "Pasar Minggu Baru",
                        destination: "Metland Telaga Murni",
                        date: "Kemarin",
                        time: "22.15",
                        onReuse: {
                            print("Reuse Metland Telaga Murni")
                            route.push(.journeySetup)
                        }
                    )
                    
                    RecentJourneyCard(
                        origin: "Sudirman",
                        destination: "Bojonggede",
                        date: "Kemarin",
                        time: "10.00",
                        onReuse: {
                            print("Reuse Metland Telaga Murni")
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    HomeView()
        .environment(Router())
}
