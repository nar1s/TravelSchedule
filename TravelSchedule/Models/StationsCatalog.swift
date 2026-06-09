//
//  StationsCatalog.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 26.05.2026.
//

struct StationsCatalog: Sendable {
    let cities: [City]
    let stationsByCityId: [String: [Station]]

    func stations(in city: City) -> [Station] {
        stationsByCityId[city.id] ?? []
    }
}
