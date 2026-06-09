//
//  CarriersListView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct CarriersListView: View {
    @StateObject private var viewModel: CarriersListViewModel
    @Environment(AppDependencies.self) private var dependencies

    init(store: SearchStore) {
        _viewModel = StateObject(wrappedValue: CarriersListViewModel(store: store))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("\(viewModel.fromTitle ?? "") → \(viewModel.toTitle ?? "")")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            ZStack {
                if isLoadingInitial {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
        }
        .background(Color(.ypWhite).ignoresSafeArea())
        .overlay(alignment: .bottom) {
            Button {
                viewModel.openFilter()
            } label: {
                HStack(spacing: 4) {
                    Text("Уточнить время")
                    if viewModel.filter.isActive {
                        Circle()
                            .fill(.ypRed)
                            .frame(width: 8, height: 8)
                    }
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.ypWhiteUniversal)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color(.ypBlue))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding([.horizontal, .top], 16)
            }
            .disabled(isFilterButtonDisabled)
        }
        .task {
            await viewModel.search()
        }
        .onAppear {
            viewModel.refreshFilteredCarriers()
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(carriers) { carrier in
                    NavigationLink(destination: CarrierView(
                        carrier: carrier,
                        networkClient: dependencies.networkClient
                    )) {
                        CarrierCardView(carrier: carrier)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(.ypBlack))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var carriers: [Carrier] {
        if case .loaded(let carriers) = viewModel.state {
            return carriers
        }
        return []
    }

    private var isLoadingInitial: Bool {
        switch viewModel.state {
        case .idle, .loading:
            return true
        case .empty, .loaded, .failed:
            return false
        }
    }

    private var isEmpty: Bool {
        if case .empty = viewModel.state {
            return true
        }
        return false
    }

    private var isFilterButtonDisabled: Bool {
        switch viewModel.state {
        case .loaded, .empty, .failed:
            return false
        case .idle, .loading:
            return true
        }
    }
}
