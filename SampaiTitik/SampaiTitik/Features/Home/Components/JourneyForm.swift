//
//  JourneyForm.swift
//  SampaiTitik
//
//  Created by Salman on 26/08/26.
//

import SwiftUI

struct JourneyForm: View {
    @State var vm: HomeViewModel

    var body: some View {
        VStack {
            VStack(spacing: 16){
                Text("Stasiun Asal")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                
                StationPickerButton(iconName: "train.side.front.car", selection:  vm.departStation){
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
                }
                
                Text("Stasiun Tujuan")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                StationPickerButton(iconName: "paperplane.fill", selection: vm.destStation){
                    vm.showDestination.toggle()
                }
                .sheet(isPresented: $vm.showDestination){
                    SearchStationView(selectedStation: $vm.destStation, isPresented: $vm.showDestination)
                }
                
                Button{
                    
                } label: {
                    Text("Selanjutnya")
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .font(.headline)

                }
                .buttonStyle(.borderedProminent)
                .tint(.blue.opacity(0.8))
                .padding(.top, 32)

            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.white)
            .cornerRadius(20)
        }
    }
}
