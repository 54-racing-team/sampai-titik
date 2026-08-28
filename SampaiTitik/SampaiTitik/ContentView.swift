//
//  ContentView.swift
//  SampaiTitik
//
//  Created by 54Racing on 21/08/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var vm = StationViewModel()
    @Query private var stations: [StationModel]
    
    var body: some View {
        VStack {
            Text("Sampai, Titik.")
            
            ScrollView {
                ForEach(stations) { station in
                    HStack {
                        Text(station.id)
                        Text(station.name)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            vm.getStations(context: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
