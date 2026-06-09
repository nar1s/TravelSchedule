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
    @ObservationIgnored private let store: SearchStore
    
    var from: Station? {
        get {
            access(keyPath: \.from)
            return store.from
        }
        set {
            withMutation(keyPath: \.from) {
                store.from = newValue
            }
        }
    }
    
    var to: Station? {
        get {
            access(keyPath: \.to)
            return store.to
        }
        set {
            withMutation(keyPath: \.to) {
                store.to = newValue
            }
        }
    }
    
    var path: [Route] {
        get {
            access(keyPath: \.path)
            return store.path
        }
        set {
            withMutation(keyPath: \.path) {
                store.path = newValue
            }
        }
    }
    
    var canSearch: Bool {
        access(keyPath: \.path)
        return from != nil && to != nil
    }
    
    var fromTitle: String? {
        access(keyPath: \.path)
        return from?.title
    }
    
    var toTitle: String? {
        access(keyPath: \.path)
        return to?.title
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
    }
}
