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
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Color(.ypWhite)
                .ignoresSafeArea()

            TabView {
                MainScreenView()
                    .overlay { errorOverlay }
                    .tabItem {
                        Image(.schedule)
                            .renderingMode(.template)
                            .accessibilityLabel("Расписание")
                    }

                SettingsView()
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
            .onChange(of: connectivity.isOnline) { _, isOnline in
                guard isOnline else { return }
                if store.carriersError == .noInternet {
                    store.carriersError = nil
                }
                Task {
                    if store.catalog == nil {
                        await store.loadCatalog()
                    }
                    let onCarriers = store.path.last == .carriers
                    let needsRetry = onCarriers
                        && !store.isLoadingCarriers
                        && store.carriers.isEmpty
                    if needsRetry {
                        await store.search()
                    }
                }
            }
            .onChange(of: scenePhase) {_, new in
                guard new == .active, connectivity.isOnline else { return }
                if store.carriersError == .noInternet {
                    store.carriersError = nil
                }
                Task {
                    if store.catalog == nil {
                        await store.loadCatalog()
                    }
                    let onCarriers = store.path.last == .carriers
                    let needsRetry = onCarriers
                    && !store.isLoadingCarriers
                    && store.carriers.isEmpty
                    if needsRetry {
                        await store.search()
                    }
                }
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
    MainTabView()
        .environment(SearchStore.preview)
        .environment(ConnectivityMonitor())
}
