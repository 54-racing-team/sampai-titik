//
//  ContentView.swift
//  SampaiTitik
//
//  Created by 54Racing on 21/08/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    // Environment
    @Environment(\.modelContext) private var modelContext
    
    // State
    @State var vm = StationViewModel()
    @State private var router: Router = .init()
    
    // Swift data
    @Query private var stations: [StationModel]
    
    var body: some View {
        SplashScreen {
            RouterView()
        }
    }
}

#Preview {
    RootView()
}
