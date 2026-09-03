//
//  JourneyPageView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import SwiftUI
import SwiftData

struct JourneyPageView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(WatchManager.self) var watchManager
    @State var viewModel: JourneyPageMainVM
    @State private var isCancel: Bool = false
    @Environment(Router.self) private var router
    
    init(stations: [JourneyStation] = JourneyStation.sampleStations) {
        self._viewModel = State(wrappedValue: JourneyPageMainVM(stations: stations))
    }
    
    var body: some View {
        ZStack {
            Color.backgroundBlue
                .ignoresSafeArea()
            
            VStack {
                JourneyCard(viewModel: viewModel)
                
                VStack(alignment: .leading) {
                    Text("Aplikasi memantau perjalananmu di latar belakang.")
                    //                    Text("Kamu bisa keluar dari aplikasi.")
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .foregroundStyle(Color.secondary)
                
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
                .tint(Color.backgroundCard)
                .padding(.horizontal)
            }
            .sheet(isPresented: $isCancel) {
                JourneyPageCancelSheet {
                    viewModel.stopJourneyTracking()
                    viewModel.addRecentJourney(context: modelContext)
                    isCancel = false
                    router.popToRoot()
                }
                .presentationDetents([.fraction(0.5)])
                .presentationBackground(Color(.secondarySystemBackground))
                .presentationDragIndicator(.visible)
            }
            .navigationTitle("Perjalanan")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.startTrackingIfPossible()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    JourneyPageView()
        .environment(Router())
        .environment(WatchManager())
}
