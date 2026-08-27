//
//  HomeView.swift
//  SampaiTitik
//
//  Created by Salman on 26/08/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color(Color("PrimaryColor"))
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack{
                    Text("Sampai.")
                        .font(.title.bold())
                        .foregroundStyle(.blue)
                    
                    Spacer()
                    
                    Button{
                        
                    } label: {
                        Image(systemName: "person.fill")
                    }
                    .padding()
                    .glassEffect()
                    .background(Color.white)
                    .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Mau kemana, Salman?")
                        .font(.title2.bold())
                    
                    Text("Siapkan perjalananmu, kami bantu mengingatkan saat sudah dekat.")
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.blue)
                
                JourneyForm(vm: HomeViewModel())
                
                Text("Pengingat tetap bekerja saat kamu tidak sedang melihat layar.")
                    .font(.caption)
                
                Text("Rute Terakhir")
                    .font(.body.bold())
                    .foregroundStyle(Color.blue)
                
                LastRouteCard()
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    HomeView()
}
