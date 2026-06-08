//
//  StationModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

struct Station: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let cityId: String
}
