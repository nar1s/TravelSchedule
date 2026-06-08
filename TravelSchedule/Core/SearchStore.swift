//
//  SearchStore.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import Observation
import Foundation
import SwiftUI

@MainActor
@Observable
final class SearchStore {
    var from: Station?
    var to: Station?
    var path: [Route] = []
    var catalog: StationsCatalog?
    var carriers: [Carrier] = []
    var isLoadingCarriers: Bool = false
    var carriersError: AppError?
    var filter: FilterState = FilterState()

    var filteredCarriers: [Carrier] {
        var result = carriers

        if !filter.selectedTimeSlots.isEmpty {
            let calendar = Calendar.current
            result = result.filter { carrier in
                let hour = calendar.component(.hour, from: carrier.departure)
                return filter.selectedTimeSlots.contains { slot in
                    slot.hourRange.contains(hour)
                }
            }
        }

        return result
    }

    @ObservationIgnored
    private let dependencies: AppDependencies

    @ObservationIgnored
    private let iso8601Formatters: [ISO8601DateFormatter] = {
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]

        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return [fractional, plain]
    }()

    @ObservationIgnored
    private let dateFormatters: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        return formats.map { format in
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.calendar = Calendar(identifier: .gregorian)
            f.isLenient = false
            f.dateFormat = format
            return f
        }
    }()

    @ObservationIgnored
    private let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func setStation(_ station: Station, for direction: TripDirection) {
        switch direction {
        case .from: from = station
        case .to:   to = station
        }
        path.removeAll()
        carriers = []
        filter = FilterState()
    }

    func swap() {
        let tmp = from
        from = to
        to = tmp
    }

    func loadCatalog() async {
        do {
            let response = try await dependencies.networkClient.getAllStations()
            catalog = mapToCatalog(response)
        } catch {
            catalog = nil
        }
    }

    func search() async {
        guard let from, let to else { return }

        carriers = []
        isLoadingCarriers = true
        carriersError = nil

        let searchDate = Calendar.current.startOfDay(for: Date())
        let apiDate = apiDateFormatter.string(from: searchDate)

        do {
            let response = try await dependencies.networkClient.searchSchedule(
                from: from.id,
                to: to.id,
                date: apiDate,
                transfers: filter.showWithTransfers
            )
            carriers = mapToCarriers(response, searchDate: searchDate)
        } catch {
            carriersError = ErrorMapper.map(error)
            carriers = []
        }
        isLoadingCarriers = false
    }

    func loadCarrierDetails(id: String) async throws -> CarrierDetails {
        let response = try await dependencies.networkClient.getCarrierInfo(code: id)

        guard let carrier = response.carrier else {
            return CarrierDetails(email: "", phone: "")
        }

        let email = carrier.email ?? ""
        let phone = carrier.phone ?? ""
        return CarrierDetails(email: email, phone: phone)
    }

    func applyFilter(_ newFilter: FilterState) async {
        let needsRefetch = filter.showWithTransfers != newFilter.showWithTransfers
        filter = newFilter
        if needsRefetch {
            await search()
        }
    }
    
    func recoverOnReconnect() async {
        if self.carriersError == .noInternet {
            self.carriersError = nil
        }

        async let catalogLoad: Void = loadCatalogIfNeeded()
        async let searchRetry: Void = retryCarriersSearchIfNeeded()

        await catalogLoad
        await searchRetry
    }
    
    @MainActor
    private func loadCatalogIfNeeded() async {
        if self.catalog == nil {
            await self.loadCatalog()
        }
    }
    
    @MainActor
    private func retryCarriersSearchIfNeeded() async {
        let needsRetry = self.path.last == .carriers
            && !self.isLoadingCarriers
            && self.carriers.isEmpty
        if needsRetry {
            await self.search()
        }
    }

    private func parseDate(_ string: String?, baseDate: Date?) -> Date? {
        guard let string, !string.isEmpty else { return nil }

        for formatter in iso8601Formatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }

        for formatter in dateFormatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }

        guard let baseDate else { return nil }

        if let match = string.range(of: #"^\d{2}:\d{2}(:\d{2})?$"#, options: .regularExpression) {
            let value = String(string[match])
            let parts = value.split(separator: ":").compactMap { Int($0) }
            guard parts.count == 2 || parts.count == 3 else { return nil }

            let hours = parts[0]
            let minutes = parts[1]
            let seconds = parts.count == 3 ? parts[2] : 0

            var calendar = Calendar.current
            calendar.timeZone = .current

            var components = calendar.dateComponents([.year, .month, .day], from: baseDate)
            components.hour = hours
            components.minute = minutes
            components.second = seconds

            return calendar.date(from: components)
        }

        return nil
    }

    private func mapToCarriers(_ response: Search, searchDate: Date) -> [Carrier] {
        let segments: [Components.Schemas.Segment] = response.segments ?? []
        let calendar = Calendar.current

        let carriers: [Carrier] = segments.compactMap { segment -> Carrier? in
            guard let uid = segment.thread?.uid, !uid.isEmpty else { return nil }

            guard
                let departure = parseDate(segment.departure, baseDate: searchDate),
                let parsedArrival = parseDate(segment.arrival, baseDate: searchDate)
            else { return nil }

            let arrival: Date
            if parsedArrival < departure {
                arrival = calendar.date(byAdding: .day, value: 1, to: parsedArrival) ?? parsedArrival
            } else {
                arrival = parsedArrival
            }

            return Carrier(
                id: uid,
                title: segment.thread?.carrier?.title ?? "Без названия",
                logoURL: (segment.thread?.carrier?.logo).flatMap { URL(string: $0) },
                departure: departure,
                arrival: arrival,
                duration: TimeInterval(segment.duration ?? 0),
                hasTransfers: segment.has_transfers ?? false,
                carrierCode: segment.thread?.carrier?.code.map { String($0) }
            )
        }

        return carriers.sorted { $0.departure < $1.departure }
    }

    private func mapToCatalog(_ response: StationsList) -> StationsCatalog {
        var citiesDict: [String: City] = [:]
        var stationsDict: [String: [Station]] = [:]

        let russiaCountries = response.countries?.filter { country in
            country.codes?.yandex_code == "l225"
        } ?? []

        for country in russiaCountries {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    let cityId = settlement.codes?.yandex_code ?? ""
                    let cityTitle = settlement.title ?? ""

                    guard !cityId.isEmpty, !cityTitle.isEmpty else { continue }

                    var stations: [Station] = []
                    var seenStationIds = Set<String>()
                    for stationData in settlement.stations ?? [] {
                        let transportType = stationData.transport_type ?? ""
                        guard transportType == "train"
                            || transportType == "suburban"
                            || transportType == "plane"
                        else { continue }

                        let stationId = stationData.codes?.yandex_code ?? ""
                        let stationTitle = stationData.title ?? ""

                        guard !stationId.isEmpty,
                              !stationTitle.isEmpty,
                              !seenStationIds.contains(stationId)
                        else { continue }

                        seenStationIds.insert(stationId)
                        stations.append(Station(
                            id: stationId,
                            title: stationTitle,
                            cityId: cityId
                        ))
                    }

                    guard !stations.isEmpty else { continue }
                    citiesDict[cityId] = City(id: cityId, title: cityTitle)
                    stationsDict[cityId] = stations
                }
            }
        }

        let cities = citiesDict.values.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
        return StationsCatalog(cities: cities, stationsByCityId: stationsDict)
    }
}

extension SearchStore {
    static var preview: SearchStore {
        let store = SearchStore(dependencies: AppDependencies.preview)
        
        store.catalog = StationsCatalog(
            cities: [
                City(id: "c213", title: "Москва"),
                City(id: "c2", title: "Санкт-Петербург")
            ],
            stationsByCityId: [
                "c213": [
                    Station(id: "s1", title: "Ленинградский вокзал", cityId: "c213"),
                    Station(id: "s2", title: "Казанский вокзал", cityId: "c213")
                ],
                "c2": [
                    Station(id: "s3", title: "Московский вокзал", cityId: "c2")
                ]
            ]
        )
        return store
    }
}
