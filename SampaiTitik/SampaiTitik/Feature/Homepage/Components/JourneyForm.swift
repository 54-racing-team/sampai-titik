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
            VStack(spacing: 16) {
                Text("Stasiun Asal")
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                
                StationPickerButton(iconName: "tram.fill", selection:  vm.departStation){
                    vm.showDeparture.toggle()
                }
                .sheet(isPresented: $vm.showDeparture) {
                    SearchStationView(
                        stations: vm.allStations,
                        selectedStation: $vm.departStation,
                        isPresented: $vm.showDeparture,
                        showNearestStation: true
                    )
                }

                Button {
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
                .sheet(isPresented: $vm.showDestination) {
                    SearchStationView(
                        stations: vm.allStations,
                        selectedStation: $vm.destStation,
                        isPresented: $vm.showDestination
                    )
                }

                Button {
                    guard let departure = vm.departStation,
                          let destination = vm.destStation else { return }
                    router.push(.journeySetup(departure: departure, destination: destination))
                } label: {
                    Text("Selanjutnya")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .padding(10)
                }
                .buttonStyle(.glassProminent)
                .tint(.mainBlue)
                .disabled(!vm.isReadyToProceed)
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color("BackgroundCard"))
            .cornerRadius(20)
        }
    }
}

#Preview {
    JourneyForm(vm: HomeViewModel())
        .environment(Router())
}
