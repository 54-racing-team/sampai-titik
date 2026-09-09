//
//  JourneySetupPageView.swift
//  SampaiTitik Watch App
//
//  Created by Muhammad Muthi' Nuritzan on 29/08/26.
//

import SwiftUI

struct JourneySetupPageView: View {
//    @State var isAlarmOn: Bool = true
    @Environment(Router.self) var route
    @State var watchManager = WatchManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Atur Perjalanan")
                    .font(.title3.bold())
                    .foregroundStyle(.mainBlue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    RecentJourneySymbol()
                    
                    VStack(alignment: .leading, spacing: 12){
                        Text(watchManager.selectedJourney?.origin ?? "Origin")
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(watchManager.selectedJourney?.destination ?? "Destination")
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle("Alarm", isOn: $watchManager.isAlarmOn)
                    .padding(10)
                    .glassEffect(.regular, in: Capsule())
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Action
                    route.push(.detailJourneyPage)
                    watchManager.sendStartJourney(
                        startJourney(
                            selectedJourney: watchManager.selectedJourney!,
                            alarmConfig: setAlarm(isAlarmOn: watchManager.isAlarmOn)
                        )
                    )
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

#Preview {
    JourneySetupPageView()
        .environment(Router())
}
