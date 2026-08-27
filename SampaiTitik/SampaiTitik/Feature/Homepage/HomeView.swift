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
            Color(Color("BackgroundBlue"))
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack{
                    Image("AppLogo")
                    
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
                        .font(.title.bold())
                    
                    Text("Siapkan perjalananmu, kami bantu mengingatkan saat sudah dekat.")
                }
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.blue)
//                .background(.black)
                
                JourneyForm()
                
                Text("Pengingat tetap bekerja saat kamu tidak sedang melihat layar.")
                    .font(.caption)
                
                VStack(alignment: .leading) {
                    Text("Rute Terakhir")
                        .font(.body.bold())
                        .foregroundStyle(Color.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Kemarin . 22.15")
                            .foregroundStyle(.gray)
                            .font(.caption)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Pasar Minggu Baru")
                                Text("Metland Telaga Murni")
                            }
                            .font(.subheadline.bold())
                            
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Text("Pakai lagi")
                                    .padding(.horizontal, 4)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .cornerRadius(20)

                    
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
}
