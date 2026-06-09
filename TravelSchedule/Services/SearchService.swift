//
//  SearchService.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

typealias Search = Components.Schemas.Segments

protocol SearchServiceProtocol: Sendable {
    func getScheduleBetweenStations(from: String, to: String, date: String?, transfers: Bool) async throws -> Search
}

final class SearchService: BaseService, SearchServiceProtocol {
    func getScheduleBetweenStations(from: String, to: String, date: String?, transfers: Bool) async throws -> Search {
        let response = try await client.getSchedualBetweenStations(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            date: date,
            transfers: transfers
        ))
        return try response.ok.body.json
    }
}
