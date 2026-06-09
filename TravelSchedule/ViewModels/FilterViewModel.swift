//
//  FilterViewModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 05.06.2026.
//

import Foundation
import Combine

@MainActor
final class FilterViewModel: ObservableObject {
    @Published var draft: FilterState
    
    private let store: SearchStore
    
    init(store: SearchStore) {
        self.store = store
        self.draft = store.filter
    }
    
    func toggle(_ slot: TimeSlot) {
        if draft.selectedTimeSlots.contains(slot) {
            draft.selectedTimeSlots.remove(slot)
        } else {
            draft.selectedTimeSlots.insert(slot)
        }
    }
    
    func setTransfers(_ value: Bool) {
        draft.showWithTransfers = value
    }
    
    func apply() async {
        await store.applyFilter(draft)
    }
}
