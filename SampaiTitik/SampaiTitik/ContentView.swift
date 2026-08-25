//
//  ContentView.swift
//  SampaiTitik
//
//  Created by 54Racing on 21/08/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var vm = StationViewModel()
    
    var body: some View {
        VStack {
            Text("Sampai, Titik.")
            
            ScrollView {
                ForEach(vm.stations) { station in
                    HStack {
                        Text(station.id)
                        Text(station.name)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            vm.getStations()
        }
    }
}

#Preview {
    ContentView()
}
