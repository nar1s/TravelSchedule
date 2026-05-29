//
//  TravelScheduleApp.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import SwiftUI

@main
struct TravelScheduleApp: App {
    @State private var store: SearchStore?
    @State private var connectivityMonitor: ConnectivityMonitor?

    var body: some Scene {
        WindowGroup {
            if let store, let monitor = connectivityMonitor {
                RootView()
                    .environment(store)
                    .environment(monitor)
            } else {
                Text("Не удалось инициализировать приложение")
            }
        }
    }

    private static func makeStore() -> (store: SearchStore?, monitor: ConnectivityMonitor?) {
        guard let dependencies = try? AppDependencies(apikey: Constants.apiKey) else {
            return (nil, nil)
        }
        return (SearchStore(dependencies: dependencies), dependencies.connectivityMonitor)
    }

    init() {
        let result = Self.makeStore()
        _store = State(initialValue: result.store)
        _connectivityMonitor = State(initialValue: result.monitor)
    }
}
