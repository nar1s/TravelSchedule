//
//  CopyrightService.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

typealias Copyright = Components.Schemas.CopyrightResponse

protocol CopyrightServiceProtocol: Sendable {
    func getCopyright(format: String) async throws -> Copyright
}

final class CopyrightService: BaseService, CopyrightServiceProtocol {
    func getCopyright(format: String) async throws -> Copyright {
        let response = try await client.getCopyright(query: .init(
            apikey: apikey,
            format: format
        ))
        return try response.ok.body.json
    }
}
