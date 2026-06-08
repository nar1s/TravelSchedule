//
//  CarriersListViewModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 05.06.2026.
//

import Foundation
import Combine

@MainActor
final class CarriersListViewModel: ObservableObject {
    @Published var fromTitle: String?
    @Published var toTitle: String?
    @Published var filteredCarriers: [Carrier] = []
    @Published var isLoading: Bool = false
    @Published var error: AppError?
    @Published var filter: FilterState = FilterState()
    
    private let store: SearchStore
    
    init(store: SearchStore) {
        self.store = store
        self.fromTitle = store.from?.title
        self.toTitle = store.to?.title
        self.filteredCarriers = store.filteredCarriers
        self.isLoading = store.isLoadingCarriers
        self.error = store.carriersError
        self.filter = store.filter
    }
    
    func search() async {
        isLoading = true
        await store.search()
        self.fromTitle = store.from?.title
        self.toTitle = store.to?.title
        self.filteredCarriers = store.filteredCarriers
        self.isLoading = store.isLoadingCarriers
        self.error = store.carriersError
        self.filter = store.filter
    }
    
    func openFilter() {
        store.path.append(.filter)
    }
    
    func refreshFilteredCarriers() {
        self.filter = store.filter
        self.filteredCarriers = store.filteredCarriers
    }
}
