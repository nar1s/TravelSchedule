//
//  CarriersListView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct CarriersListView: View {
    @Environment(SearchStore.self) private var store
    @State private var viewModel: CarriersListViewModel?

    var body: some View {
        VStack(spacing: 0) {
            if let viewModel {
                Text("\(viewModel.fromTitle ?? "") → \(viewModel.toTitle ?? "")")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                ZStack {
                    if viewModel.isLoading && viewModel.filteredCarriers.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.filteredCarriers.isEmpty {
                        emptyView
                    } else {
                        contentView(viewModel: viewModel)
                    }
                }
            }
        }
        .background(Color(.ypWhite).ignoresSafeArea())
        .overlay(alignment: .bottom) {
            if let viewModel {
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
                .disabled(viewModel.filteredCarriers.isEmpty && !viewModel.isLoading)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = CarriersListViewModel(store: store)
            }
            guard let viewModel else { return }
            guard !viewModel.isLoading, viewModel.filteredCarriers.isEmpty else { return }
            await viewModel.search()
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private func contentView(viewModel: CarriersListViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredCarriers) { carrier in
                    NavigationLink(destination: CarrierView(carrier: carrier)) {
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
}

#Preview {
    NavigationStack {
        CarriersListView()
            .environment(SearchStore.preview)
    }
}
