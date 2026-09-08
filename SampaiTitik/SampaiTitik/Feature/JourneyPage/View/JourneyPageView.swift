//
//  JourneyPageView.swift
//  SampaiTitik
//
//  Created by Muhammad Muthi' Nuritzan on 24/08/26.
//

import SwiftData
import SwiftUI

struct JourneyPageView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(WatchManager.self) var watchManager

    @State var viewModel: JourneyPageMainVM

    @State private var isCancel: Bool = false
    @Environment(Router.self) private var router

    // Observed Notificationm
    let userArriveNotification = NotificationCenter.default.publisher(
        for: .userArrived
    )

    init(
        stations: [JourneyStation] = JourneyStation.sampleStations,
        soundName: String? = nil
    ) {
        self._viewModel = State(
            wrappedValue: JourneyPageMainVM(
                stations: stations,
                soundName: soundName
            )
        )
    }

    var body: some View {
        ZStack {
            Color.backgroundBlue
                .ignoresSafeArea()

            VStack {
                JourneyCard(viewModel: viewModel)

                VStack(alignment: .leading) {
                    Text("Aplikasi memantau perjalananmu di latar belakang.")
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
                    isCancel = false
                    router.popToRoot()
                    watchManager.sendCancelJourney()
                }
                .presentationDetents([.fraction(0.5)])
                .presentationBackground(Color(.secondarySystemBackground))
                .presentationDragIndicator(.visible)
            }
            .navigationTitle("Perjalanan")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            Task {
                await viewModel.startTrackingIfPossible(
                    modelContext: modelContext
                )
            }
            watchManager.sendJourneyTracking(
                journeyTracking(
                    destination: viewModel.destinationName,
                    currentStation: viewModel.currentStationName,
                    nextStation: viewModel.nextStationName,
                    stationRemaining: viewModel.remainingStationsCount
                )
            )
        }
        .onReceive(userArriveNotification) { output in
            Task {
                try await Task.sleep(for: .seconds(3))

                // Pop back to root & complete Watch journey
                await MainActor.run {
                    router.popToRoot()
                    watchManager.sendFinsihJourney()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    JourneyPageView()
        .environment(Router())
        .environment(WatchManager.shared)
}
