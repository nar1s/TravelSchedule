//
//  NetworkClient.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 07.06.2026.
//

import Foundation

protocol NetworkClientProtocol: Sendable {
    func getAllStations() async throws -> StationsList
    func searchSchedule(
        from: String,
        to: String,
        date: String?,
        transfers: Bool
    ) async throws -> Search
    func getCarrierInfo(code: String) async throws -> CarrierResponse
}

actor NetworkClient: NetworkClientProtocol {

    private let stationsListService: any StationsListServiceProtocol
    private let searchService: any SearchServiceProtocol
    private let carrierService: any CarrierServiceProtocol
    private let connectivityMonitor: ConnectivityMonitor

    init(
        stationsListService: any StationsListServiceProtocol,
        searchService: any SearchServiceProtocol,
        carrierService: any CarrierServiceProtocol,
        connectivityMonitor: ConnectivityMonitor
    ) {
        self.stationsListService = stationsListService
        self.searchService = searchService
        self.carrierService = carrierService
        self.connectivityMonitor = connectivityMonitor
    }

    func getAllStations() async throws -> StationsList {
        guard await connectivityMonitor.isOnline else {
            throw AppError.noInternet
        }
        return try await stationsListService.getAllStations()
    }

    func searchSchedule(
        from: String,
        to: String,
        date: String?,
        transfers: Bool
    ) async throws -> Search {
        guard await connectivityMonitor.isOnline else {
            throw AppError.noInternet
        }
        return try await searchService.getScheduleBetweenStations(
            from: from,
            to: to,
            date: date,
            transfers: transfers
        )
    }

    func getCarrierInfo(code: String) async throws -> CarrierResponse {
        guard await connectivityMonitor.isOnline else {
            throw AppError.noInternet
        }
        return try await carrierService.getCarrierInfo(code: code)
    }
}
