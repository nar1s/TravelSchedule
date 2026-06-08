//
//  MainScreenView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import SwiftUI

struct MainScreenView: View {
    @State private var viewModel: MainScreenViewModel
    @Environment(SearchStore.self) private var store
    @Environment(AppDependencies.self) private var dependencies
    
    init(store: SearchStore) {
        _viewModel = State(initialValue: MainScreenViewModel(store: store))
    }
    
    var body: some View {
        NavigationStack(path: Binding(
            get: { viewModel.path },
            set: { viewModel.path = $0 }
        )) {
            
            ZStack {
                Color(.ypWhite)
                    .ignoresSafeArea()
                
                VStack(spacing: 44) {
                    StoriesBar()
                        .padding(.horizontal, 16)
                    
                    searchCard
                        .padding(.horizontal, 16)
                    
                    if viewModel.canSearch {
                        Button {
                            viewModel.search()
                        } label: {
                            Text("Найти")
                                .frame(width: 150, height: 60)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color(.ypWhiteUniversal))
                                .background(Color(.ypBlue))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationDestination(for: Route.self) { route in
                destinationView(for: route)
            }
        }
    }
    
    @ViewBuilder
    private var searchCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 0) {
                StationField(
                    title: "Откуда",
                    stationTitle: viewModel.fromTitle,
                    action: { viewModel.selectFromCity() }
                )
                
                StationField(
                    title: "Куда",
                    stationTitle: viewModel.toTitle,
                    action: { viewModel.selectToCity() }
                )
            }
            .background(Color(.ypWhiteUniversal))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Button(action: { viewModel.swap() }) {
                Circle()
                    .fill(Color(.ypWhiteUniversal))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(.switch)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundStyle(Color(.ypBlue))
                            .frame(width: 20, height: 20)
                    }
            }
        }
        .padding(16)
        .background(Color(.ypBlue))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .cityList(let direction):
            Group {
                if let catalog = store.catalog {
                    SearchableListView(
                        title: "Выбор города",
                        items: catalog.cities,
                        searchableText: { $0.title },
                        displayText: { $0.title },
                        onSelect: { city in
                            store.path.append(.stationList(direction: direction, city: city))
                        },
                        emptyMessage: "Город не найден"
                    )
                }
            }
            .environment(dependencies)
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
            }
            
        case .stationList(let direction, let city):
            Group {
                if let catalog = store.catalog {
                    SearchableListView(
                        title: "Выбор станции",
                        items: catalog.stations(in: city),
                        searchableText: { $0.title },
                        displayText: { $0.title },
                        onSelect: { station in
                            store.setStation(station, for: direction)
                        },
                        emptyMessage: "Станция не найдена"
                    )
                }
            }
            .environment(dependencies)
            .toolbar(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton()
                }
            }
            
        case .carriers:
            CarriersListView(store: store)
                .environment(dependencies)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButton()
                    }
                }
            
        case .filter:
            FilterView(store: store)
                .environment(dependencies)
                .toolbar(.hidden, for: .tabBar)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        BackButton()
                    }
                }
        }
    }
}

private struct StationField: View {
    let title: String
    let stationTitle: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(stationTitle ?? title)
                    .foregroundStyle(stationTitle == nil ? Color(.ypGray) : Color(.ypBlackUniversal))
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    return MainScreenView(store: SearchStore.preview)
        .environment(SearchStore.preview)
        .environment(AppDependencies.preview)
}
