//
//  JourneyPageView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import SwiftUI

struct JourneyPageView: View {
    @State var viewModel: JourneyPageMainVM
    @State private var isCancel: Bool = false

    init(stations: [JourneyStation] = JourneyStation.sampleStations) {
        self._viewModel = State(wrappedValue: JourneyPageMainVM(stations: stations))
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            VStack {
                Text("Perjalanan")
                    .font(.title)
                    .fontWeight(.semibold)

                JourneyCard(viewModel: viewModel)

                VStack(alignment: .leading) {
                    Text("Aplikasi memantau perjalananmu di latar belakang.")
                    Text("Kamu bisa mengunci layar")
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Spacer()

                Button {
                    isCancel = true
                } label: {
                    Text("Akhiri Perjalanan")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                }
                .buttonStyle(.glassProminent)
                .tint(.red)
                .padding(.horizontal)
            }
            .sheet(isPresented: $isCancel) {
                JourneyPageCancelSheet {
                    viewModel.stopJourneyTracking()
                }
                .presentationDetents([.fraction(0.5)])
                .presentationBackground(.white)
                .presentationDragIndicator(.visible)
            }
        }
//        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        JourneyPageView()
    }
}
