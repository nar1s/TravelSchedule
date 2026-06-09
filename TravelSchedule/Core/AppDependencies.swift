//
//  AppDependencies.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession
import Observation

@Observable
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
    let connectivityMonitor: ConnectivityMonitor

    let networkClient: any NetworkClientProtocol

    init(apikey: String) throws {
        let client = try Client(
            serverURL: Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        self.client = client

        let carrierService = CarrierService(client: client, apikey: apikey)
        let copyrightService = CopyrightService(client: client, apikey: apikey)
        let nearestCityService = NearestCityService(client: client, apikey: apikey)
        let nearestStationsService = NearestStationsService(client: client, apikey: apikey)
        let scheduleService = ScheduleService(client: client, apikey: apikey)
        let searchService = SearchService(client: client, apikey: apikey)
        let stationsListService = StationsListService(client: client, apikey: apikey)
        let threadService = ThreadService(client: client, apikey: apikey)
        let connectivityMonitor = ConnectivityMonitor()

        self.carrierService = carrierService
        self.copyrightService = copyrightService
        self.nearestCityService = nearestCityService
        self.nearestStationsService = nearestStationsService
        self.scheduleService = scheduleService
        self.searchService = searchService
        self.stationsListService = stationsListService
        self.threadService = threadService
        self.connectivityMonitor = connectivityMonitor

        self.networkClient = NetworkClient(
            stationsListService: stationsListService,
            searchService: searchService,
            carrierService: carrierService,
            connectivityMonitor: connectivityMonitor
        )
    }
}

extension AppDependencies: @unchecked Sendable { }

extension AppDependencies {
    static var preview: AppDependencies {
        do {
            return try AppDependencies(apikey: Constants.apiKey)
        } catch {
            fatalError("\(error)")
        }
    }
}
