//
//  MainScreenViewModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 05.06.2026.
//

import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
final class MainScreenViewModel {
    private let store: SearchStore
    
    var from: Station? {
        get { store.from }
        set { store.from = newValue }
    }
    
    var to: Station? {
        get { store.to }
        set { store.to = newValue }
    }
    
    var path: [Route] {
        get { store.path }
        set { store.path = newValue }
    }
    
    var canSearch: Bool {
        from != nil && to != nil
    }
    
    var fromTitle: String? {
        from?.title
    }
    
    var toTitle: String? {
        to?.title
    }
    
    init(store: SearchStore) {
        self.store = store
    }
    
    func selectFromCity() {
        store.path.append(.cityList(direction: .from))
    }
    
    func selectToCity() {
        store.path.append(.cityList(direction: .to))
    }
    
    func swap() {
        store.swap()
    }
    
    func search() {
        store.path.append(.carriers)
        Task { await store.search() }
    }
}
