//
//  CarrierModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import Foundation

struct Carrier: Identifiable, Hashable {
    let id: String
    let title: String
    let logoURL: URL?
    let departure: Date
    let arrival: Date
    let duration: TimeInterval
    let hasTransfers: Bool
    let carrierCode: String?
}
