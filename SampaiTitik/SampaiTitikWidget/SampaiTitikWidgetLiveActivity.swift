//
//  SampaiTitikWidgetLiveActivity.swift
//  SampaiTitikWidget
//
//  Created by Salman on 26/08/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SampaiTitikWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SampaiTitikWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
//                Text("Hello \(context.state.emoji)")
                Text(context.attributes.trainLine)
                Text(context.state.currentStation)
                Text(context.state.nextStation)
            }
            .activityBackgroundTint(Color.red)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.currentStation)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.trainLine)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.nextStation)
                }
                DynamicIslandExpandedRegion(.center) {
                    ProgressView(value: context.state.progress)
                }
            } compactLeading: {
                Text(context.state.currentStation)
                    .font(.caption)
            } compactTrailing: {
                Text(context.state.nextStation)
                    .font(.caption)
            } minimal: {
                Image(systemName: "tram.fill")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SampaiTitikWidgetAttributes {
    fileprivate static var preview: SampaiTitikWidgetAttributes {
        // SESUAIKAN: Gunakan parameter trainLine
        SampaiTitikWidgetAttributes(trainLine: "KRL Central Line")
    }
}

extension SampaiTitikWidgetAttributes.ContentState {
    // SESUAIKAN: Buat data mock dengan currentStation, nextStation, dan progress
    fileprivate static var state1: SampaiTitikWidgetAttributes.ContentState {
        SampaiTitikWidgetAttributes.ContentState(
            currentStation: "Tebet",
            nextStation: "Manggarai",
            progress: 0.3
        )
    }
    
    fileprivate static var state2: SampaiTitikWidgetAttributes.ContentState {
        SampaiTitikWidgetAttributes.ContentState(
            currentStation: "Manggarai",
            nextStation: "Cikini",
            progress: 0.7
        )
    }
}

#Preview("Notification", as: .content, using: SampaiTitikWidgetAttributes.preview) {
   SampaiTitikWidgetLiveActivity()
} contentStates: {
    SampaiTitikWidgetAttributes.ContentState.state1
    SampaiTitikWidgetAttributes.ContentState.state2
}
