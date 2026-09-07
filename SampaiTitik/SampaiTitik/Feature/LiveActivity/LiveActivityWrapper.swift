//
//  LiveActivityView.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 27/08/26.
//

import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<LiveActivityAttributes>?
    
    private init() {}
    
    func startJourneyActivity(
        appTitle: String = "SampaiTitik",
        journeyCaption: String = "Perjalanan",
        startStation: String,
        endStation: String,
        currentStationCode: String,
        currentStationName: String,
        nextStationCode: String,
        nextStationName: String,
        isSoundEnabled: Bool = true
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled on this device.")
            return
        }
        
        endActivity()
        
        let attributes = LiveActivityAttributes(
            appTitle: appTitle,
            journeyCaption: journeyCaption,
            startStation: startStation,
            endStation: endStation,
            id: UUID()
        )
        
        let initialContentState = LiveActivityAttributes.ContentState(
            isOnJourney: true,
            currentStation: currentStationCode,
            remainingTime: "5 min",
            remainingStation: nextStationCode,
            currentStationCode: currentStationCode,
            currentStationName: currentStationName,
            nextStationCode: nextStationCode,
            nextStationName: nextStationName,
            isMuted: !isSoundEnabled,
            isSoundEnabled: isSoundEnabled
        )
        
        let activityContent = ActivityContent(state: initialContentState, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
            print("Live Activity started successfully: \(currentActivity?.id ?? "")")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateJourneyActivity(
        currentStationCode: String,
        currentStationName: String,
        nextStationCode: String,
        nextStationName: String,
        remainingTime: String = "5 min",
        isSoundEnabled: Bool = true
    ) {
        guard let activity = currentActivity else { return }
        
        let updatedState = LiveActivityAttributes.ContentState(
            isOnJourney: true,
            currentStation: currentStationCode,
            remainingTime: remainingTime,
            remainingStation: nextStationCode,
            currentStationCode: currentStationCode,
            currentStationName: currentStationName,
            nextStationCode: nextStationCode,
            nextStationName: nextStationName,
            isMuted: !isSoundEnabled,
            isSoundEnabled: isSoundEnabled
        )
        
        Task {
            await activity.update(ActivityContent(state: updatedState, staleDate: nil))
        }
    }
    
    func endActivity() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.currentActivity = nil
        }
    }
}


