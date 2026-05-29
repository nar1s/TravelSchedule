//
//  StationsListService.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias StationsList = Components.Schemas.AllStationsResponse

protocol StationsListServiceProtocol {
    func getAllStations() async throws -> StationsList
}

final class StationsListService: BaseService, StationsListServiceProtocol {
    func getAllStations() async throws -> StationsList {
        let response = try await client.getAllStations(query: .init(
            apikey: apikey
        ))
        
        let responseBody = try response.ok.body.html

        let limit = 50 * 1024 * 1024
        let fullData = try await Data(collecting: responseBody, upTo: limit)

        let stationsList = try JSONDecoder().decode(StationsList.self, from: fullData)

        return stationsList
    }
}
