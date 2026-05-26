//
//  MainTabView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            MainScreenView()
                .tabItem {
                    Label("Расписание", systemImage: "arrow.up.arrow.down")
                }

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environment(SearchStore.preview)
}
