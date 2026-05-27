//
//  APITestRunner.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

final class APITestRunner {
    private let client: Client
    private let apikey: String

    init(apikey: String) throws {
        self.client = try Client(
            serverURL: Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        self.apikey = apikey
    }

    func runAll() async {
        print("===== API TEST SUITE START =====")
        await testFetchStations()
        await testFetchCarrierInfo()
        await testFetchCopyright()
        await testFetchNearestCity()
        let threadUID = await testFetchStationSchedule()
        await testFetchSearchBetweenStations()
        await testFetchStationsList()
        await testFetchThreadRoute(uid: threadUID)
        print("===== API TEST SUITE END =====")
    }

    private func logStart(_ testName: String) {
        print("[START] \(testName)")
    }

    private func logSuccess(_ testName: String, result: Any) {
        print("[SUCCESS] \(testName)")
        print("Result: \(shortDescription(result))")
    }

    private func logFailure(_ testName: String, error: Error) {
        print("[FAIL] \(testName): \(error.localizedDescription)")
    }

    private func logSkip(_ testName: String, reason: String) {
        print("[SKIP] \(testName): \(reason)")
    }

    private func shortDescription(_ value: Any, limit: Int = 220) -> String {
        let text = String(describing: value)
        if text.count <= limit {
            return text
        }

        let prefix = text.prefix(limit)
        return "\(prefix)... [truncated]"
    }

    private func testFetchStations() async {
        let testName = "NearestStationsService.getNearestStations"
        logStart(testName)

        do {
            let service = NearestStationsService(
                client: client,
                apikey: apikey
            )

            let stations = try await service.getNearestStations(
                lat: 59.864177,
                lng: 30.319163,
                distance: 50
            )
            logSuccess(testName, result: stations)
        } catch {
            logFailure(testName, error: error)
        }
    }

    private func testFetchCarrierInfo() async {
        let testName = "CarrierService.getCarrierInfo"
        logStart(testName)

        do {
            let service = CarrierService(
                client: client,
                apikey: apikey
            )

            let carrier = try await service.getCarrierInfo(code: "680")
            logSuccess(testName, result: carrier)
        } catch {
            logFailure(testName, error: error)
        }
    }

    private func testFetchCopyright() async {
        let testName = "CopyrightService.getCopyright"
        logStart(testName)

        do {
            let service = CopyrightService(
                client: client,
                apikey: apikey
            )

            let copyright = try await service.getCopyright(format: "json")
            logSuccess(testName, result: copyright)
        } catch {
            logFailure(testName, error: error)
        }
    }

    private func testFetchNearestCity() async {
        let testName = "NearestCityService.getNearestCity"
        logStart(testName)

        do {
            let service = NearestCityService(
                client: client,
                apikey: apikey
            )

            let city = try await service.getNearestCity(
                lat: 59.864177,
                lng: 30.319163
            )
            logSuccess(testName, result: city)
        } catch {
            logFailure(testName, error: error)
        }
    }

    private func testFetchStationSchedule() async -> String? {
        let testName = "ScheduleService.getStationSchedule"
        logStart(testName)

        do {
            let service = ScheduleService(
                client: client,
                apikey: apikey
            )

            let schedule = try await service.getStationSchedule(station: "s9600213")
            logSuccess(testName, result: schedule)
            return schedule.schedule?.first?.thread?.uid
        } catch {
            logFailure(testName, error: error)
            return nil
        }
    }

    private func testFetchSearchBetweenStations() async {
        let testName = "SearchService.getScheduleBetweenStations"
        logStart(testName)

        do {
            let service = SearchService(
                client: client,
                apikey: apikey
            )

            let search = try await service.getScheduleBetweenStations(
                from: "c213",
                to: "c20735",
                transfers: true
            )
            logSuccess(testName, result: search)
        } catch {
            logFailure(testName, error: error)
        }
    }

    private func testFetchStationsList() async {
        let testName = "StationsListService.getAllStations"
        logStart(testName)

        do {
            let service = StationsListService(
                client: client,
                apikey: apikey
            )

            let stationsList = try await service.getAllStations()
            logSuccess(testName, result: stationsList)
        } catch {
            logFailure(testName, error: error)
        }
    }

    private func testFetchThreadRoute(uid: String?) async {
        let testName = "ThreadService.getRouteStations"
        logStart(testName)

        guard let uid else {
            logSkip(testName, reason: "UID not found from previous schedule response")
            return
        }

        do {
            let service = ThreadService(
                client: client,
                apikey: apikey
            )

            let thread = try await service.getRouteStations(uid: uid)
            logSuccess(testName, result: thread)
        } catch {
            logFailure(testName, error: error)
        }
    }
}
