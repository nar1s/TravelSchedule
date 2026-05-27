//
//  CarriersListView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct CarriersListView: View {
    @Environment(SearchStore.self) private var store

    var body: some View {
        VStack(spacing: 0) {
            Text("\(store.from?.title ?? "") → \(store.to?.title ?? "")")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            ZStack {
                if store.isLoadingCarriers && store.carriers.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.filteredCarriers.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
        }
        .background(Color(.ypWhite).ignoresSafeArea())
        .overlay(alignment: .bottom) {
            Button {
                store.path.append(.filter)
            } label: {
                HStack(spacing: 4) {
                    Text("Уточнить время")
                    if store.filter.isActive {
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
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .disabled(store.carriers.isEmpty)
        }
        .task {
            guard !store.isLoadingCarriers, store.carriers.isEmpty else { return }
            await store.search()
        }
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(store.filteredCarriers) { carrier in
                    NavigationLink(destination: CarrierView(carrierName: carrier.title)) {
                        CarrierCardView(carrier: carrier)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("Вариантов нет")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color(.ypBlack))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CarriersListView()
            .environment(SearchStore.preview)
    }
}
