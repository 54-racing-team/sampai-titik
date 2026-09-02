//
//  JourneyForm.swift
//  SampaiTitik
//
//  Created by Salman on 26/08/26.
//

import SwiftUI

struct JourneyForm: View {
    @Environment(Router.self) private var router
    
    @State var vm = HomeViewModel()
    

    var body: some View {
        VStack {
            VStack(spacing: 12){
                Text("Stasiun Asal")
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                
                StationPickerButton(iconName: "tram.fill", selection:  vm.departStation){
                    vm.showDeparture.toggle()
                }
                .sheet(isPresented: $vm.showDeparture) {
                    SearchStationView(selectedStation: $vm.departStation, isPresented: $vm.showDeparture)
                }
                
                Button{
                    vm.swapStations()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.headline)
                        .rotationEffect(.degrees(vm.isRotating ? 180 : 0))
                        .foregroundStyle(.mainBlue)
                }
                
                Text("Stasiun Tujuan")
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                                
                StationPickerButton(iconName: "location.fill", selection: vm.destStation){
                    vm.showDestination.toggle()
                }
                .sheet(isPresented: $vm.showDestination){
                    SearchStationView(selectedStation: $vm.destStation, isPresented: $vm.showDestination)
                }
                
                CardButton(title: "Selanjutnya") {
                    router.push(.journeySetup(data: "abc"))
                }
                .padding(.top, 12)

            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color("BackgroundCard"))
            .cornerRadius(20)
        }
    }
}
