//
//  HomeView.swift
//  SampaiTitik
//
//  Created by Salman on 26/08/26.
//

import SwiftUI
import SwiftData
struct HomeView: View {
    @State var stationVM = StationViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            Color(Color("PrimaryColor"))
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack{
                    Text("Sampai.")
                        .font(.title)
                        .foregroundStyle(.blue)
                    
                    Spacer()
                    
                    Button{
                        
                    } label: {
                        Image(systemName: "person.fill")
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Mau kemana, Salman?")
                        .font(.title2.bold())
                    
                    Text("Siapkan perjalananmu, kami bantu mengingatkan saat sudah dekat.")
                }
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.blue)
                
                JourneyForm()
                
                Text("Pengingat tetap bekerja saat kamu tidak sedang melihat layar.")
                    .font(.caption)
                
                VStack(alignment: .leading) {
                    Text("Rute Terakhir")
                        .font(.body.bold())
                        .foregroundStyle(Color.blue)
                    
                    RecentJourneyCard(
                        origin: "Pasar Minggu Baru",
                        destination: "Metland Telaga Murni",
                        date: "Kemarin",
                        time: "22.15",
                        onReuse: {
                            print("Reuse Metland Telaga Murni")
                        }
                    )                }
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
}
