//
//  CarriersListView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import SwiftUI

struct CarriersListView: View {
    @Environment(SearchStore.self) private var store
    @State private var showFilter = false

    var body: some View {
        ZStack {
            if store.isLoadingCarriers && store.carriers.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = store.carriersError {
                errorView(for: error)
            } else if store.filteredCarriers.isEmpty {
                emptyView
            } else {
                contentView
            }
        }
        .navigationTitle("Расписание")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFilter = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Уточнить")
                        if store.filter.isActive {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .disabled(store.carriers.isEmpty)
            }
        }
        .sheet(isPresented: $showFilter) {
            FilterView()
        }
        .task {
            guard !store.isLoadingCarriers, store.carriers.isEmpty else { return }
            await store.search()
        }
    }

    // MARK: - Content

    private var contentView: some View {
        List(store.filteredCarriers) { carrier in
            CarrierRow(carrier: carrier)
        }
        .listStyle(.plain)
        .refreshable {
            await store.search()
        }
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tram.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(store.carriers.isEmpty ? "Ничего не найдено" : "Нет рейсов по фильтру")
                .font(.title3)
                .foregroundStyle(.secondary)

            if store.filter.isActive {
                Button("Сбросить фильтр") {
                    store.filter = FilterState()
                }
                .buttonStyle(.bordered)
            } else {
                Button("Попробовать снова") {
                    Task { await store.search() }
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error

    private func errorView(for error: AppError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: errorIcon(for: error))
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(errorMessage(for: error))
                .font(.title3)
                .foregroundStyle(.secondary)

            Button("Повторить") {
                Task { await store.search() }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorIcon(for error: AppError) -> String {
        switch error {
        case .noInternet: "wifi.slash"
        case .server: "exclamationmark.icloud"
        case .decoding, .unknown: "questionmark"
        }
    }

    private func errorMessage(for error: AppError) -> String {
        switch error {
        case .noInternet: "Нет интернета"
        case .server: "Ошибка сервера"
        case .decoding: "Ошибка данных"
        case .unknown: "Неизвестная ошибка"
        }
    }
}

// MARK: - CarrierRow

struct CarrierRow: View {
    let carrier: Carrier

    var body: some View {
        HStack(spacing: 12) {
            logoView
                .frame(width: 38, height: 38)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(carrier.title)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Text(carrier.departure, style: .time)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(carrier.arrival, style: .time)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                if carrier.hasTransfers {
                    Text("С пересадкой")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            Text(durationText(from: carrier.duration))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var logoView: some View {
        if let url = carrier.logoURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                default:
                    placeholderLogo
                }
            }
        } else {
            placeholderLogo
        }
    }

    private var placeholderLogo: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "tram.fill")
                    .foregroundStyle(.secondary)
            }
    }

    private func durationText(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        if hours > 0 {
            return "\(hours) ч \(minutes) мин"
        }
        return "\(minutes) мин"
    }
}

// MARK: - FilterView

struct FilterView: View {
    @Environment(SearchStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: FilterState = FilterState()

    var body: some View {
        NavigationStack {
            Form {
                Section("Время отправления") {
                    ForEach(TimeSlot.allCases) { slot in
                        Toggle(isOn: Binding(
                            get: { draft.selectedTimeSlots.contains(slot) },
                            set: { isOn in
                                if isOn {
                                    draft.selectedTimeSlots.insert(slot)
                                } else {
                                    draft.selectedTimeSlots.remove(slot)
                                }
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(slot.rawValue)
                                Text(slot.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Пересадки") {
                    Toggle("Показывать рейсы с пересадками", isOn: $draft.showWithTransfers)
                }
            }
            .navigationTitle("Уточнить время")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Сбросить") {
                        draft = FilterState()
                    }
                    .disabled(!draft.isActive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Применить") {
                        let newFilter = draft
                        dismiss()
                        Task { await store.applyFilter(newFilter) }
                    }
                }
            }
            .onAppear {
                draft = store.filter
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CarriersListView()
            .environment(SearchStore.preview)
    }
}
