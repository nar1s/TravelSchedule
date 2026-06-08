//
//  MainTabView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct MainTabView: View {
    @Environment(SearchStore.self) private var store
    @Environment(ConnectivityMonitor.self) private var connectivity
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Color(.ypWhite)
                .ignoresSafeArea()

            TabView {
                MainScreenView(store: store)
                    .environment(dependencies)
                    .overlay { errorOverlay }
                    .tabItem {
                        Image(.schedule)
                            .renderingMode(.template)
                            .accessibilityLabel("Расписание")
                    }

                SettingsView()
                    .environment(dependencies)
                    .overlay { errorOverlay }
                    .tabItem {
                        Image(.settings)
                            .renderingMode(.template)
                            .accessibilityLabel("Настройки")
                    }
            }
            .tint(.primary)
            .toolbarBackground(Color(.ypWhite), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .task(id: connectivity.isOnline) {
                guard connectivity.isOnline else { return }
                await store.recoverOnReconnect()
            }
            .task(id: scenePhase) {
                guard scenePhase == .active, connectivity.isOnline else { return }
                await store.recoverOnReconnect()
            }
        }
    }

    private var showNoInternet: Bool {
        !connectivity.isOnline || store.carriersError == .noInternet
    }

    @ViewBuilder
    private var errorOverlay: some View {
        if showNoInternet {
            NoInternetView()
                .transition(.opacity)
        } else if store.carriersError == .server {
            ServerErrorView()
                .transition(.opacity)
        }
    }
}

#Preview {
    return MainTabView()
        .environment(SearchStore.preview)
        .environment(ConnectivityMonitor())
        .environment(AppDependencies.preview)
}
