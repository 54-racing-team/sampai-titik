//
//  SampaiTitikWidgetLiveActivity.swift
//  SampaiTitikWidget
//
//  Created by Ahmad Yasri Zaenuri on 07/09/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct SampaiTitikWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            DeliveryLiveActivityView(
                attributes: context.attributes,
                state: context.state
            )
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI layout
                DynamicIslandExpandedRegion(.leading) {
                    DynamicIslandExpandedHeaderLeading()
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    DynamicIslandExpandedHeaderTrailing(isSoundEnabled: context.state.displayIsSoundEnabled)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    DynamicIslandExpandedBottomView(state: context.state)
                }
            } compactLeading: {
                HStack(spacing: 2) {
                    Text(context.state.displayCurrentCode)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    
                    Image(systemName: "chevron.forward.dotted.chevron.forward")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(Color.blue)
                .padding(.leading, 4)
            } compactTrailing: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.forward.dotted.chevron.forward")
                        .font(.system(size: 12, weight: .bold))
                    
                    Text(context.state.displayNextCode)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color.blue)
                .padding(.trailing, 4)
            } minimal: {
                Image(systemName: "tram.fill")
                    .foregroundColor(Color.blue)
            }
            .widgetURL(URL(string: "sampaititik://journey"))
            .keylineTint(Color.blue)
        }
    }
}

// MARK: - Expanded Dynamic Island Components

struct DynamicIslandExpandedHeaderLeading: View {
    var body: some View {
        HStack(spacing: 0) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 30)
        }
        .padding(.leading, 4)
    }
}

struct DynamicIslandExpandedHeaderTrailing: View {
    let isSoundEnabled: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSoundEnabled ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 28, height: 28)
            
            Image(systemName: isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSoundEnabled ? .white : Color.gray)
        }
        .padding(.trailing, 4)
    }
}

struct DynamicIslandExpandedBottomView: View {
    let state: LiveActivityAttributes.ContentState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Station Labels
            HStack {
                Text("Stasiun saat ini")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Stasiun selanjutnya")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white)
            }
            
            // Station Codes & Connection Track
            HStack(alignment: .center, spacing: 8) {
                Text(state.displayCurrentCode)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Connection track graphics
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 3)
                    
                    HStack(spacing: -5) {
                        Image(systemName: "chevron.forward.dotted.chevron.forward")
                            .modifier(ChevronAnimationModifier())
                    }
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color.yellow)
                    
                    // Dashed line
                    Line()
                        .stroke(
                            Color.gray.opacity(0.6),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5])
                        )
                        .frame(height: 2)
                    
                    // Target station concentric ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                            .frame(width: 14, height: 14)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Text(state.displayNextCode)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Full Station Names
            HStack {
                Text(state.displayCurrentName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.blue)
                
                Spacer()
                
                Text(state.displayNextName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.blue)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}

struct ChevronAnimationModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.symbolEffect(.drawOn.individually, options: .repeat(.periodic(delay: 1.0)))
        } else {
            content.symbolEffect(.variableColor.iterative, options: .repeat(.periodic(delay: 1.0)))
        }
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

// MARK: - Lock Screen Live Activity View

struct DeliveryLiveActivityView: View {
    let attributes: LiveActivityAttributes
    let state: LiveActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "tram.fill")
                    .foregroundColor(.blue)
                    .font(.title2)

                VStack(alignment: .leading) {
                    Text(attributes.appTitle)
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
                        .foregroundColor(.blue)
                }
            }

            HStack {
                Text("\(state.displayCurrentName) → \(state.displayNextName)")
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
}

// MARK: - Xcode Previews

struct ExpandedDynamicIslandPreviewView: View {
    let state: LiveActivityAttributes.ContentState
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    DynamicIslandExpandedHeaderLeading()
                    Spacer()
                    DynamicIslandExpandedHeaderTrailing(isSoundEnabled: state.displayIsSoundEnabled)
                }
                
                DynamicIslandExpandedBottomView(state: state)
            }
            .padding(16)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview("Expanded Dynamic Island Canvas") {
    ExpandedDynamicIslandPreviewView(
        state: LiveActivityAttributes.ContentState(
            isOnJourney: true,
            currentStation: "SUD",
            remainingTime: "5 min",
            remainingStation: "MRI",
            currentStationCode: "SUD",
            currentStationName: "Sudirman",
            nextStationCode: "MRI",
            nextStationName: "Manggarai",
            isMuted: true
        )
    )
}

struct CompactDynamicIslandPreviewView: View {
    let state: LiveActivityAttributes.ContentState
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 16) {
                HStack(spacing: 2) {
                    Text(state.displayCurrentCode)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Image(systemName: "chevron.forward.dotted.chevron.forward")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(Color.blue)
                
                Spacer()
                    .frame(width: 80)
                
                HStack(spacing: 2) {
                    Image(systemName: "chevron.forward.dotted.chevron.forward")
                        .font(.system(size: 12, weight: .bold))
                    Text(state.displayNextCode)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color.blue)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview("Compact Dynamic Island Canvas") {
    CompactDynamicIslandPreviewView(
        state: LiveActivityAttributes.ContentState(
            isOnJourney: true,
            currentStation: "SUDB",
            remainingTime: "5 min",
            remainingStation: "KRAM",
            currentStationCode: "SUDB",
            currentStationName: "Sudirman Baru",
            nextStationCode: "KRAM",
            nextStationName: "Kramat",
            isMuted: false
        )
    )
}

#Preview(
    "Widget Dynamic Island",
    as: .dynamicIsland(.expanded),
    using: LiveActivityAttributes.preview
) {
    SampaiTitikWidgetLiveActivity()
} contentStates: {
    LiveActivityAttributes.ContentState(
        isOnJourney: true,
        currentStation: "SUD",
        remainingTime: "5 min",
        remainingStation: "MRI",
        currentStationCode: "SUD",
        currentStationName: "Sudirman",
        nextStationCode: "MRI",
        nextStationName: "Manggarai",
        isMuted: true
    )
}
