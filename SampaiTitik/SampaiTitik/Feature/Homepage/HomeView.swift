//
//  HomeView.swift
//  SampaiTitik
//
//  Created by Salman on 26/08/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject private var scheduler = AlarmSchedulerManager.shared
    @State var stationVM = StationViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) var router
    
    @Query(sort: \RecentJourneyModel.date, order: .reverse) var recentJourneys: [RecentJourneyModel]
    
    var body: some View {
        ZStack {
            Color(Color("BackgroundBlue"))
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack{
                    Image("AppLogo")
                    
                    Spacer()

                    Button {

                    } label: {
                        Image(systemName: "person.fill")
                        .foregroundStyle(.mainBlue)
                    }
                    .padding()
                    .background(Color("BackgroundCard"))
                    .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Mau kemana, Salman?")
                        .font(.title.bold())
                    
                    Text("Siapkan perjalananmu, kami bantu mengingatkan saat sudah dekat.")
                        .font(.body)
                }
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)

                JourneyForm()

                Text(
                    "Pengingat tetap bekerja saat kamu tidak sedang melihat layar."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("Rute Terakhir")
                        .font(.body.bold())
                        .foregroundStyle(Color.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(recentJourneys.prefix(3)) { journey in
                                RecentJourneyCard(
                                    origin: journey.origin,
                                    destination: journey.destination,
                                    date: journey.date,
                                    time: journey.date
                                ){
                                    let allStations = StationModelDTO.loadFromJSON()
                                    if let departureDTO = allStations.first(where: { $0.name == journey.origin }),
                                       let destinationDTO = allStations.first(where: { $0.name == journey.destination }) {
                                        
                                        router.push(.journeySetup(departure: departureDTO, destination: destinationDTO))
                                    }
                                }
                                .frame(width: 320)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            stationVM.getStations(context: modelContext)
            
            let journeys = recentJourneys.prefix(5).map {
                recentJourney(date: $0.date, origin: $0.origin, destination: $0.destination)
            }
            WatchManager.shared.sendRecentJourney(journeys)
            
        }
    }
}

#Preview {
    HomeView()
        .environment(Router())
}
