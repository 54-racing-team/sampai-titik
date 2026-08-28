//
//  HomeView.swift
//  SampaiTitik
//
//  Created by Salman on 26/08/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var scheduler = AlarmSchedulerManager.shared

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
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Mau kemana, Salman?")
                        .font(.title.bold())
                    
                    Text("Siapkan perjalananmu, kami bantu mengingatkan saat sudah dekat.")
                        .font(.body)
                    
                }
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.mainBlue)
                .fixedSize(horizontal: false, vertical: true)

                JourneyForm()

                Text(
                    "Pengingat tetap bekerja saat kamu tidak sedang melihat layar."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text("Rute Terakhir")
                        .font(.body.bold())
                        .foregroundStyle(Color.mainBlue)
                    
                    RecentJourneyCard(
                        origin: "Pasar Minggu Baru", destination: "Metland Telaga Murni", date: "Kemarin", time: "22.15", onReuse: {print("Reuse Metland Telaga Murni")}
                    )

                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    HomeView()
        .environment(Router())
}
