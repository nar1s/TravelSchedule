//
//  RootView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 26.05.2026.
//

import SwiftUI

private enum AppPhase {
    case splash
    case main
}

struct RootView: View {
    @Environment(SearchStore.self) private var store
    @Environment(AppDependencies.self) private var dependencies
    @State private var phase: AppPhase = .splash

    var body: some View {
        ZStack {
            Color(.ypWhite)
                .ignoresSafeArea()

            switch phase {
            case .splash:
                SplashView()
                    .task {
                        async let minDelay: Void = Task.sleep(for: .seconds(1.5))
                        async let catalog: Void = store.loadCatalog()
                        _ = await (try? minDelay, catalog)

                        withAnimation(.easeInOut(duration: 0.25)) {
                            phase = .main
                        }
                    }
            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
    }
}
