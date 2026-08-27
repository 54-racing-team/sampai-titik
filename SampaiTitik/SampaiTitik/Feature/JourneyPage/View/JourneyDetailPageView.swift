//
//  JourneyDetailPageView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import SwiftUI

struct JourneyDetailPageView: View {
    var viewModel: JourneyPageDetailVM
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            ScrollView {
                JourneyDetailCard(viewModel: viewModel)
            }
            .navigationTitle("Detail Perjalanan")
        }
    }
}

#Preview {
    NavigationStack {
        JourneyDetailPageView(
            viewModel: JourneyPageDetailVM()
        )
    }
}
