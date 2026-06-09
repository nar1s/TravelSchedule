//
//  ThreadService.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

typealias Thread = Components.Schemas.ThreadStationsResponse

protocol ThreadServiceProtocol: Sendable {
    func getRouteStations(uid: String) async throws -> Thread
}

final class ThreadService: BaseService, ThreadServiceProtocol {
    func getRouteStations(uid: String) async throws -> Thread {
        let response = try await client.getRouteStations(query: .init(
            apikey: apikey,
            uid: uid
        ))
        return try response.ok.body.json
    }
}
