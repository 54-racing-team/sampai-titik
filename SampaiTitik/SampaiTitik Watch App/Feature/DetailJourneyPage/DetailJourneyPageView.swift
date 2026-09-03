//
//  MainPage.swift
//  SampaiTitik Watch App
//
//  Created by Muhammad Muthi' Nuritzan on 30/08/26.
//

import SwiftUI

struct DetailJourneyPageView: View {
    @State private var selectedTab:Int = 2
    @Environment(Router.self) var route
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Halaman 1
            CancelJourneyPage()
                .tag(1)
            
            // Halaman 2
            InformationJourneyPage()
                .tag(2)
        }
        .tabViewStyle(.page)
        .navigationBarHidden(true)
    }
}

#Preview {
    DetailJourneyPageView()
        .environment(Router())
}
