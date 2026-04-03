//
//  ContentView.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 02.04.2026.
//

import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            runAllServiceTests()
        }
    }

    private func makeClient() throws -> Client {
        try Client(
            serverURL: Servers.Server1.url(),
            transport: URLSessionTransport()
        )
    }

    private func runAllServiceTests() {
        Task {
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

    func testFetchStations() async {
        let testName = "NearestStationsService.getNearestStations"
        logStart(testName)

        do {
            let service = NearestStationsService(
                client: try makeClient(),
                apikey: Constants.apiKey
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

    func testFetchCarrierInfo() async {
        let testName = "CarrierService.getCarrierInfo"
        logStart(testName)

        do {
            let service = CarrierService(
                client: try makeClient(),
                apikey: Constants.apiKey
            )

            let carrier = try await service.getCarrierInfo(code: "680")
            logSuccess(testName, result: carrier)
        } catch {
            logFailure(testName, error: error)
        }
    }

    func testFetchCopyright() async {
        let testName = "CopyrightService.getCopyright"
        logStart(testName)

        do {
            let service = CopyrightService(
                client: try makeClient(),
                apikey: Constants.apiKey
            )

            let copyright = try await service.getCopyright(format: "json")
            logSuccess(testName, result: copyright)
        } catch {
            logFailure(testName, error: error)
        }
    }

    func testFetchNearestCity() async {
        let testName = "NearestCityService.getNearestCity"
        logStart(testName)

        do {
            let service = NearestCityService(
                client: try makeClient(),
                apikey: Constants.apiKey
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

    func testFetchStationSchedule() async -> String? {
        let testName = "ScheduleService.getStationSchedule"
        logStart(testName)

        do {
            let service = ScheduleService(
                client: try makeClient(),
                apikey: Constants.apiKey
            )

            let schedule = try await service.getStationSchedule(station: "s9600213")
            logSuccess(testName, result: schedule)
            return schedule.schedule?.first?.thread?.uid
        } catch {
            logFailure(testName, error: error)
            return nil
        }
    }

    func testFetchSearchBetweenStations() async {
        let testName = "SearchService.getSchedualBetweenStations"
        logStart(testName)

        do {
            let service = SearchService(
                client: try makeClient(),
                apikey: Constants.apiKey
            )

            let search = try await service.getSchedualBetweenStations(
                from: "c213",
                to: "c20735"
            )
            logSuccess(testName, result: search)
        } catch {
            logFailure(testName, error: error)
        }
    }

    func testFetchStationsList() async {
        let testName = "StationsListService.getAllStations"
        logStart(testName)

        do {
            let service = StationsListService(
                client: try makeClient(),
                apikey: Constants.apiKey
            )

            let stationsList = try await service.getAllStations()
            logSuccess(testName, result: stationsList)
        } catch {
            logFailure(testName, error: error)
        }
    }

    func testFetchThreadRoute(uid: String?) async {
        let testName = "ThreadService.getRouteStations"
        logStart(testName)

        guard let uid else {
            logSkip(testName, reason: "UID not found from previous schedule response")
            return
        }

        do {
            let service = ThreadService(
                client: try makeClient(),
                apikey: Constants.apiKey
            )

            let thread = try await service.getRouteStations(uid: uid)
            logSuccess(testName, result: thread)
        } catch {
            logFailure(testName, error: error)
        }
    }
}

#Preview {
    ContentView()
}
