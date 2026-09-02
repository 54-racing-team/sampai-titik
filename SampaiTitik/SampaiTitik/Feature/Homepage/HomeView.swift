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
<<<<<<< HEAD
                .foregroundStyle(Color.blue)
=======
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
>>>>>>> trial

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
<<<<<<< HEAD
                        .foregroundStyle(Color.blue)
                    
                    RecentJourneyCard(
                        origin: "Pasar Minggu Baru",
                        destination: "Metland Telaga Murni",
                        date: "Kemarin",
                        time: "22.15",
                        onReuse: {
                            print("Reuse Metland Telaga Murni")
                        }
=======
                        .foregroundStyle(Color.primary)
                    
                    RecentJourneyCard(
                        origin: "Pasar Minggu Baru", destination: "Metland Telaga Murni", date: "Kemarin", time: "22.15", onReuse: {print("Reuse Metland Telaga Murni")}
>>>>>>> trial
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            stationVM.getStations(context: modelContext)
        }
    }
}

#Preview {
    HomeView()
        .environment(Router())
}
