//
//  ContentView.swift
//  SampaiTitik
//
//  Created by 54Racing on 21/08/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        SplashScreen {
            RouterView()
        }
    }
}

#Preview {
    RootView()
}
