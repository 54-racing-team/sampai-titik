//
//  HomeView.swift
//  SampaiTitik
//
//  Created by Salman on 30/08/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) var route
    @State var watchManager = WatchManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rute Terakhir")
                .font(.title3.bold())
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Color("MainBlue"))
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(watchManager.recentJouneys, id: \.self){ journey in
                        RecentJourneyCard(
                            origin: journey.origin,
                            destination: journey.destination,
                            date: journey.date,
                            time: journey.date,
                            onReuse: {
                                watchManager.selectedJourney = journey
                                route.push(.journeySetup)
                            }
                        )
                    }
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
