//
//  MainScreenView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import SwiftUI

struct MainScreenView: View {
    @Environment(SearchStore.self) private var store

    var body: some View {
        @Bindable var bindableStore = store

        NavigationStack(path: $bindableStore.path) {
            VStack(spacing: 16) {
                Text("Главный экран")
                    .font(.title2)

                VStack(spacing: 12) {
                    StationField(
                        title: "Откуда",
                        stationTitle: store.from?.title,
                        action: { store.path.append(.cityList(direction: .from)) }
                    )

                    Button(action: store.swap) {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundStyle(.blue)
                    }

                    StationField(
                        title: "Куда",
                        stationTitle: store.to?.title,
                        action: { store.path.append(.cityList(direction: .to)) }
                    )
                }
                .padding()

                if store.from != nil && store.to != nil {
                    Button("Найти") {
                        store.path.append(.carriers)
                        Task { await store.search() }
                    }
                    .padding()
                }
            }
            .navigationDestination(for: Route.self) { route in
                destinationView(for: route)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .cityList(let direction):
            Group {
                if let catalog = store.catalog {
                    SearchableListView(
                        title: direction == .from ? "Откуда" : "Куда",
                        items: catalog.cities,
                        searchableText: { $0.title },
                        displayText: { $0.title },
                        onSelect: { city in
                            store.path.append(.stationList(direction: direction, city: city))
                        }
                    )
                } else {
                    Text("Загрузка...")
                }
            }
            .toolbar(.hidden, for: .tabBar)

        case .stationList(let direction, let city):
            Group {
                if let catalog = store.catalog {
                    SearchableListView(
                        title: city.title,
                        items: catalog.stations(in: city),
                        searchableText: { $0.title },
                        displayText: { $0.title },
                        onSelect: { station in
                            store.setStation(station, for: direction)
                        }
                    )
                } else {
                    Text("Загрузка...")
                }
            }
            .toolbar(.hidden, for: .tabBar)

        case .carriers:
            CarriersListView()

        case .filter:
            FilterView()
                .toolbar(.hidden, for: .tabBar)
        }
    }
}

struct StationField: View {
    let title: String
    let stationTitle: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(stationTitle ?? "Выбрать")
                    .foregroundStyle(stationTitle == nil ? .blue : .primary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

#Preview {
    MainScreenView()
        .environment(SearchStore.preview)
}
