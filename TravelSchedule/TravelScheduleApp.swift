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
    @State private var dependencies: AppDependencies?

    var body: some Scene {
        WindowGroup {
            if let store, let dependencies, let monitor = connectivityMonitor {
                RootView()
                    .environment(monitor)
                    .environment(dependencies)
                    .environment(store)
            } else {
                Text("Не удалось инициализировать приложение")
            }
        }
    }

    init() {
        let dependencies: AppDependencies
        do {
            dependencies = try AppDependencies(apikey: Constants.apiKey)
        } catch {
            print("AppDependencies init failed: \(error)")
            return
        }
        _dependencies = State(initialValue: dependencies)
        _store = State(initialValue: SearchStore(dependencies: dependencies))
        _connectivityMonitor = State(initialValue: dependencies.connectivityMonitor)
    }
}
