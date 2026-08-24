//
//  ContentView.swift
//  SampaiTitik
//
//  Created by 54Racing on 21/08/26.
//

import SwiftUI

struct StationSelectionView: View {
    @StateObject var viewModel = StationSelectionViewModel()
    
    var body: some View {
        VStack {
            VStack(spacing: 16){
                Text("Stasiun Asal")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body)
                
                StationPickerButton(iconName: "train.side.front.car", selection: viewModel.departStation){
                    viewModel.showDeparture.toggle()
                }
                .sheet(isPresented: $viewModel.showDeparture) {
                    SearchStationView(selectedStation: $viewModel.departStation, isPresented: $viewModel.showDeparture)
                }
                
                Button{
                    viewModel.swapStations()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.headline)
                        .rotationEffect(.degrees(viewModel.isRotating ? 180 : 0))
                }
                
                Text("Stasiun Tujuan")
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                StationPickerButton(iconName: "paperplane.fill", selection: viewModel.destStation){
                    viewModel.showDestination.toggle()
                }
                .sheet(isPresented: $viewModel.showDestination){
                    SearchStationView(selectedStation: $viewModel.destStation, isPresented: $viewModel.showDestination)
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
        .padding()
    }
}

#Preview {
    StationSelectionView().preferredColorScheme(.dark)
}
