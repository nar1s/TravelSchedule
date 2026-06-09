//
//  ScheduleService.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

typealias Schedule = Components.Schemas.ScheduleResponse

protocol ScheduleServiceProtocol: Sendable {
    func getStationSchedule(station: String) async throws -> Schedule
}

final class ScheduleService: BaseService, ScheduleServiceProtocol {
    func getStationSchedule(station: String) async throws -> Schedule {
        let response = try await client.getStationSchedule(query: .init(
            apikey: apikey,
            station: station
        ))
        return try response.ok.body.json
    }
    
}
