//
//  MainTabView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - Environment
    
    @Environment(SearchStore.self) private var store
    @Environment(ConnectivityMonitor.self) private var connectivity
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Body
    
    var body: some View {
        ZStack {
            backgroundView
            tabContent
        }
    }

    // MARK: - Subviews

    private var backgroundView: some View {
        Color(.ypWhite)
            .ignoresSafeArea()
    }

    private var tabContent: some View {
        TabView {
            scheduleTab
            settingsTab
        }
        .tint(.primary)
        .toolbarBackground(Color(.ypWhite), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    private var scheduleTab: some View {
        MainScreenView(store: store)
            .environment(dependencies)
            .overlay { errorOverlay }
            .tabItem {
                Image(.schedule)
                    .renderingMode(.template)
                    .accessibilityLabel("Расписание")
            }
    }

    private var settingsTab: some View {
        SettingsView()
            .environment(dependencies)
            .overlay { errorOverlay }
            .tabItem {
                Image(.settings)
                    .renderingMode(.template)
                    .accessibilityLabel("Настройки")
            }
    }

    private var connectivityRecovery: some View {
        Color.clear
            .task(id: connectivity.isOnline) {
                guard connectivity.isOnline else { return }
                await store.recoverOnReconnect()
            }
            .task(id: scenePhase) {
                guard scenePhase == .active, connectivity.isOnline else { return }
                await store.recoverOnReconnect()
            }
    }

    // MARK: - Error overlay

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

// MARK: - Preview

#Preview {
    return MainTabView()
        .environment(SearchStore.preview)
        .environment(ConnectivityMonitor())
        .environment(AppDependencies.preview)
}
