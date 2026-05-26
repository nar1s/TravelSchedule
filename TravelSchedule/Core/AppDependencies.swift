//
//  AppDependencies.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

final class AppDependencies {
    let client: Client

    let carrierService: any CarrierServiceProtocol
    let copyrightService: any CopyrightServiceProtocol
    let nearestCityService: any NearestCityServiceProtocol
    let nearestStationsService: any NearestStationsServiceProtocol
    let scheduleService: any ScheduleServiceProtocol
    let searchService: any SearchServiceProtocol
    let stationsListService: any StationsListServiceProtocol
    let threadService: any ThreadServiceProtocol

    init(apikey: String) throws {
        let client = try Client(
            serverURL: Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        self.client = client

        self.carrierService = CarrierService(client: client, apikey: apikey)
        self.copyrightService = CopyrightService(client: client, apikey: apikey)
        self.nearestCityService = NearestCityService(client: client, apikey: apikey)
        self.nearestStationsService = NearestStationsService(client: client, apikey: apikey)
        self.scheduleService = ScheduleService(client: client, apikey: apikey)
        self.searchService = SearchService(client: client, apikey: apikey)
        self.stationsListService = StationsListService(client: client, apikey: apikey)
        self.threadService = ThreadService(client: client, apikey: apikey)
    }
}
