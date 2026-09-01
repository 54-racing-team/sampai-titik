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
            Color.backgroundBlue
                .ignoresSafeArea()
            
            VStack {
                Text("Perjalanan")
                    .font(.title.bold())
                
                JourneyCard(viewModel: viewModel)

                VStack(alignment: .leading) {
                    Text("Aplikasi memantau perjalananmu di latar belakang.")
//                    Text("Kamu bisa keluar dari aplikasi.")
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Spacer()

                Button {
                    isCancel = true
                } label: {
                    Text("Batalkan Perjalanan")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                }
                .buttonStyle(.glass)
                .tint(Color(.systemBackground))
                .padding(.horizontal)
            }
            .sheet(isPresented: $isCancel) {
                JourneyPageCancelSheet {
                    viewModel.stopJourneyTracking()
                }
                .presentationDetents([.fraction(0.5)])
                .presentationBackground(Color(.secondarySystemBackground))
                .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            viewModel.startTrackingIfPossible()
        }
//        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        JourneyPageView()
    }
}
