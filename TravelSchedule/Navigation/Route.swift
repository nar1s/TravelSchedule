//
//  Route.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

enum TripDirection: Hashable, Sendable {
    case from
    case to
}

enum Route: Hashable, Sendable {
    case cityList(direction: TripDirection)
    case stationList(direction: TripDirection, city: City)
    case carriers
    case filter
}
