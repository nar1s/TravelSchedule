//
//  TravelScheduleApp.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import SwiftUI

@main
struct TravelScheduleApp: App {
    @State private var store: SearchStore? = Self.makeStore()

    var body: some Scene {
        WindowGroup {
            if let store {
                RootView()
                    .environment(store)
            } else {
                Text("Не удалось инициализировать приложение")
            }
        }
    }

    private static func makeStore() -> SearchStore? {
        guard let dependencies = try? AppDependencies(apikey: Constants.apiKey) else {
            return nil
        }
        return SearchStore(dependencies: dependencies)
    }
}
