//
//  SearchStationView.swift
//  SampaiTitik
//
//  Created by Salman on 23/08/26.
//

import SwiftUI
import SwiftData

struct SearchStationSheet: View {
    @Query var stations: [StationModel]
    
    @Binding var selectedStation: String
    @Binding var isPresented: Bool
    
    @State var searchStation: String = ""
    
    var filteredStations: [StationModel] {
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
                            Text(station.id)
                        }
                        .foregroundColor(.black)
                    }
                }
            }
            .searchable(text: $searchStation, prompt: "Cari stasiun asal...")
        }
    }
}

#Preview {
    SearchStationSheet(selectedStation: .constant(""), isPresented: .constant(false))
}
