//
//  SampaiTitikWidgetLiveActivity.swift
//  SampaiTitikWidget
//
//  Created by Bomanarakasura on 28/08/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct SampaiTitikWidgetAttributes: ActivityAttributes {
    var appTitle: String
    var journeyCaption: String
    var startStation: String
    var endStation: String
    var id: UUID

    public struct ContentState: Codable, Hashable {
        var isOnJourney: Bool
        var currentStation: String
        var remainingTime: String
        var remainingStation: String
    }
}

struct SampaiTitikWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            DeliveryLiveActivityView(
                attributes: context.attributes,
                state: context.state
            )
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom ")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T ")
            } minimal: {
                Text("fd")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SampaiTitikWidgetAttributes {
    fileprivate static var preview: SampaiTitikWidgetAttributes {
        SampaiTitikWidgetAttributes(appTitle: "Sampai Titik", journeyCaption: "Perjalanan", startStation: "MRI", endStation: "BJG", id: UUID())
    }
}

extension SampaiTitikWidgetAttributes.ContentState {
    fileprivate static var smiley: SampaiTitikWidgetAttributes.ContentState {
        SampaiTitikWidgetAttributes.ContentState(isOnJourney: true, currentStation: "LNA", remainingTime: "5 hours", remainingStation: "5")
    }
}

struct LiveActivityAttributes: ActivityAttributes {

    var appTitle: String
    var journeyCaption: String
    var startStation: String
    var endStation: String
    var id: UUID

    public struct ContentState: Codable, Hashable {
        var isOnJourney: Bool
        var currentStation: String
        var remainingTime: String
        var remainingStation: String
    }
}

extension LiveActivityAttributes {
    static var preview: LiveActivityAttributes {
        .init(
            appTitle: "SampaiTitik",
            journeyCaption: "Journey",
            startStation: "Jakarta",
            endStation: "Surabaya",
            id: .init()
        )
    }
}

struct DeliveryLiveActivityView: View {
    let attributes: LiveActivityAttributes
    let state: LiveActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "bag.fill")
                    .foregroundColor(.orange)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text("Order #\(attributes.appTitle)")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(attributes.endStation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("ETA")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(state.currentStation)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }

            // Progress indicator

            // Current status
            HStack {
                Text("\(state.currentStation) \(state.remainingStation)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    //    private func shouldShowProgress(current: DeliveryStatus, target: DeliveryStatus) -> Bool {
    //        let allCases = DeliveryStatus.allCases
    //        guard let currentIndex = allCases.firstIndex(of: current),
    //              let targetIndex = allCases.firstIndex(of: target) else {
    //            return false
    //        }
    //        return currentIndex > targetIndex
    //    }
}

#Preview(
    "Notification",
    as: .dynamicIsland(.minimal),
    using: SampaiTitikWidgetAttributes.preview
) {
    SampaiTitikWidgetLiveActivity()
} contentStates: {
    //    SampaiTitikWidgetAttributes.ContentState.smiley
    //    SampaiTitikWidgetAttributes.ContentState.starEyes
    SampaiTitikWidgetAttributes.ContentState.init(
        isOnJourney: true,
        currentStation: "MIDICIDeviceID",
        remainingTime: "5 min",
        remainingStation: "fdsaf"
    )
}
