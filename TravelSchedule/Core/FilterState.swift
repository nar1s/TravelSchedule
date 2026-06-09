//
//  FilterState.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import Foundation

enum TimeSlot: String, CaseIterable, Identifiable {
    case morning = "Утро"
    case afternoon = "День"
    case evening = "Вечер"
    case night = "Ночь"

    var id: String { rawValue }

    var hourRange: ClosedRange<Int> {
        switch self {
        case .morning:   6...11
        case .afternoon: 12...17
        case .evening:   18...23
        case .night:     0...5
        }
    }

    var subtitle: String {
        switch self {
        case .morning:   "06:00 – 12:00"
        case .afternoon: "12:00 – 18:00"
        case .evening:   "18:00 – 00:00"
        case .night:     "00:00 – 06:00"
        }
    }
}

struct FilterState: Equatable, Sendable {
    var selectedTimeSlots: Set<TimeSlot> = []
    var showWithTransfers: Bool = true

    var isActive: Bool {
        !selectedTimeSlots.isEmpty || !showWithTransfers
    }
}
