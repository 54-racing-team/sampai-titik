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
    case journeySetup(departure: StationModelDTO, destination: StationModelDTO, soundName: String? = nil, targetRadius: Double? = nil)
    case journeyPage(stations: [JourneyStation], soundName: String? = nil, targetRadius: Double? = nil)
    case confirmation(stations: [JourneyStation], soundName: String? = nil, targetRadius: Double? = nil)
    case profile
    case detail(id: String)
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
    @State private var watchManager = WatchManager.shared

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                    case .journeySetup(let departure, let destination, let soundName, let targetRadius):
                        JourneySetupPageView(
                            departure: departure,
                            destination: destination,
                            soundName: soundName,
                            targetRadius: targetRadius
                        )
                    case .confirmation(let stations, let soundName, let targetRadius):
                        ConfirmationView(stations: stations, soundName: soundName, targetRadius: targetRadius)
                    case .journeyPage(let stations, let soundName, let targetRadius):
                        JourneyPageView(stations: stations, soundName: soundName, targetRadius: targetRadius)
                    default:
                        EmptyView()
                    }
                }.onChange(of: watchManager.isOnJourney) { oldValue, newValue in
                    if newValue {
                        let origin = watchManager.activeJourney?.selectedJourney.origin ?? ""
                        let destination = watchManager.activeJourney?.selectedJourney.destination ?? ""
                        
                        let stations = JourneyRouteService.createJourneyStations(originName: origin, destinationName: destination)
                        
                        router.push(.journeyPage(stations: stations, soundName: nil, targetRadius: nil))
                    } else {
                        NotificationCenter.default.post(name: .resetJourneyForm, object: nil)
                        router.popToRoot()
                        print("journey off")
                    }
                    
                }
        }
        .environment(router)
        .environment(watchManager)
    }
}
