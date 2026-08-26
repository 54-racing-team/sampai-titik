//
//  SampaiTitikApp.swift
//  SampaiTitik
//
//  Created by 54Racing on 21/08/26.
//

import SwiftUI
import SwiftData

@main
struct SampaiTitikApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
        .modelContainer(for: StationModel.self)
    }
}
