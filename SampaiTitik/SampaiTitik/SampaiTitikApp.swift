//
//  SampaiTitikApp.swift
//  SampaiTitik
//
//  Created by 54Racing on 21/08/26.
//

import SwiftUI
import SwiftData
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        LiveActivityManager.shared.endActivitySynchronously()
    }
}

@main
struct SampaiTitikApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            StationModel.self,
            RecentJourneyModel.self
        ])
    }
}
