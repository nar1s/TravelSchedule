//
//  ConnectivityMonitor.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import Foundation
import Network
import Observation

@MainActor
@Observable
final class ConnectivityMonitor {
    private(set) var isOnline: Bool = true

    @ObservationIgnored
    private let monitor = NWPathMonitor()
    
    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    init() {
        startObserving()
    }

    deinit {
        monitor.cancel()
    }

    private func startObserving() {
        let stream = AsyncStream<Bool> { continuation in
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied)
            }
            continuation.onTermination = { [monitor] _ in
                monitor.cancel()
            }
        }

        observationTask = Task { [weak self] in
            for await isOnline in stream {
                guard let self else { return }
                if self.isOnline != isOnline {
                    self.isOnline = isOnline
                }
            }
        }
    }
}
