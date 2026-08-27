//
//  SearchStationView.swift
//  SampaiTitik
//
//  Created by Salman on 23/08/26.
//

import SwiftUI

struct Station: Identifiable {
    let id = UUID()
    let name: String
    let code: String
}

struct SearchStationView: View {
    let stations: [Station] = [
        Station(name: "Jakarta Kota", code: "JAKK"),
        Station(name: "Manggarai", code: "MRI"),
        Station(name: "Bojonggede", code: "BGD"),
        Station(name: "Bogor", code: "BOO")
    ]
    
    @Binding var selectedStation: String
    @Binding var isPresented: Bool
    @State var searchStation: String = ""
    
    var filteredStations: [Station] {
        if searchStation.isEmpty {
            stations
        } else {
            stations.filter { station in
                station.name.localizedStandardContains(searchStation)
            }
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                List(filteredStations){ station in
                    Button{
                        selectedStation = station.name
                        isPresented.toggle()
                        
                    } label: {
                        HStack{
                            Text(station.name)
                            Spacer()
                            Text(station.code)
                        }
                    }
                }
            }
            .searchable(text: $searchStation, prompt: "Cari stasiun asal...")
        }
    }
}

#Preview {
    SearchStationView(selectedStation: .constant(""), isPresented: .constant(false))
}
