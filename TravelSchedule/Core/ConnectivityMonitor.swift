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
    
    @ObservationIgnored
    private var hasStarted = false

    init() {
        startObserving()
    }

    deinit {
        monitor.cancel()
    }

    func currentPathSnapshot() async -> NWPath? {
        await withCheckedContinuation { (continuation: CheckedContinuation<NWPath?, Never>) in
            monitor.pathUpdateHandler = { path in
                continuation.resume(returning: path)
            }
        }
    }

    private func startObserving() {
        startMonitoringIfNeeded()

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

    private func startMonitoringIfNeeded() {
        guard !hasStarted else { return }
        monitor.start(queue: .global(qos: .utility))
        hasStarted = true
    }
}
