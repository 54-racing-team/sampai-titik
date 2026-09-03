//
//  Router.swift
//  SampaiTitik
//
//  Created by Bomanarakasura on 27/08/26.
//

import Foundation
import SwiftUI

enum Route: Hashable {
    case home
    case journeySetup
    case detailJourneyPage
}

@Observable
class Router {
    var path = NavigationPath()

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

struct RouterView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                    case .journeySetup:
                        JourneySetupPageView()
                    case .detailJourneyPage:
                        DetailJourneyPageView()
                    default:
                        EmptyView()
                    }
                }
        }
        .environment(router)
    }
}
