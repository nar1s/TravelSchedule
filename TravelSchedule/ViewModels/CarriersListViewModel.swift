//
//  CarriersListViewModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 05.06.2026.
//

import Foundation
import Combine

enum CarriersListState: Equatable {
    case idle
    case loading
    case empty
    case loaded([Carrier])
    case failed(AppError)
}

@MainActor
final class CarriersListViewModel: ObservableObject {
    
    @Published private(set) var state: CarriersListState = .idle
    
    @Published var fromTitle: String?
    @Published var toTitle: String?
    @Published var filter: FilterState = FilterState()
    
    private let store: SearchStore
    
    init(store: SearchStore) {
        self.store = store
        syncMetaFromStore()
    }
    
    func search() async {
        if case .loading = state { return }
        state = .loading
        await store.search()
        state = makeState(from: store)
        syncMetaFromStore()
    }

    func openFilter() {
        store.path.append(.filter)
    }
    
    func refreshFilteredCarriers() {
        state = makeState(from: store)
        syncMetaFromStore()
    }
    
    private func syncMetaFromStore() {
        self.fromTitle = store.from?.title
        self.toTitle = store.to?.title
        self.filter = store.filter
    }
    
    private func makeState(from store: SearchStore) -> CarriersListState {
        if let error = store.carriersError {
            return .failed(error)
        }
        if store.filteredCarriers.isEmpty {
            return .empty
        }
        return .loaded(store.filteredCarriers)
    }
}
