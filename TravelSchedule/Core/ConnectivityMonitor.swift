//
//  ConnectivityMonitor.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 27.05.2026.
//

import Foundation
import Network
import Observation

@Observable
final class ConnectivityMonitor {
    private(set) var isOnline: Bool = true

    @ObservationIgnored
    private let monitor = NWPathMonitor()

    @ObservationIgnored
    private let queue = DispatchQueue(label: "ConnectivityMonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            DispatchQueue.main.async {
                guard let self, self.isOnline != online else { return }
                self.isOnline = online
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
