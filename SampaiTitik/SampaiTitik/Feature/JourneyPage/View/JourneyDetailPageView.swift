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
            Color.backgroundBlue
                .ignoresSafeArea()
            
            ScrollView {
                Text("Detail Perjalanan")
                    .font(.headline)
                    .padding(.vertical, 32)
                
                JourneyDetailCard(viewModel: viewModel)
            }
        }
    }
}

#Preview {
        JourneyDetailPageView(
            viewModel: JourneyPageDetailVM()
        )
}
