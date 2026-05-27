//
//  SearchStore.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import Observation
import Foundation

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
    private let dateFormatters: [DateFormatter] = {
        let formats = [
            "HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
        ]
        return formats.map { format in
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = format
            return f
        }
    }()

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    private func parseDate(_ string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        for formatter in dateFormatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        return nil
    }

    func setStation(_ station: Station, for direction: TripDirection) {
        switch direction {
        case .from:
            from = station
        case .to:
            to = station
        }
        Task { @MainActor in
            path.removeAll()
            carriers = []
            filter = FilterState()
        }
    }

    func swap() {
        let tmp = from
        from = to
        to = tmp
    }

    func loadCatalog() async {
        do {
            let response = try await dependencies.stationsListService.getAllStations()
            catalog = mapToCatalog(response)
        } catch {
            catalog = nil
        }
    }

    func search() async {
        guard let from, let to else { return }

        guard dependencies.connectivityMonitor.isOnline else {
            carriersError = .noInternet
            isLoadingCarriers = false
            carriers = []
            return
        }

        carriers = []
        isLoadingCarriers = true
        carriersError = nil
        do {
            let response = try await dependencies.searchService
                .getScheduleBetweenStations(
                    from: from.id,
                    to: to.id,
                    transfers: filter.showWithTransfers
                )
            carriers = mapToCarriers(response)
        } catch {
            carriersError = ErrorMapper.map(error)
            carriers = []
        }
        isLoadingCarriers = false
    }

    func applyFilter(_ newFilter: FilterState) async {
        let needsRefetch = filter.showWithTransfers != newFilter.showWithTransfers
        filter = newFilter
        if needsRefetch {
            await search()
        }
    }

    private func mapToCarriers(_ response: Search) -> [Carrier] {
        let segments: [Components.Schemas.Segment] = response.segments ?? []
        let carriers: [Carrier] = segments.compactMap { segment -> Carrier? in
            guard let uid = segment.thread?.uid, !uid.isEmpty else { return nil }
            guard
                let departure = parseDate(segment.departure),
                let arrival = parseDate(segment.arrival)
            else { return nil }

            return Carrier(
                id: uid,
                title: segment.thread?.carrier?.title ?? "Без названия",
                logoURL: (segment.thread?.carrier?.logo).flatMap { URL(string: $0) },
                departure: departure,
                arrival: arrival,
                duration: TimeInterval(segment.duration ?? 0),
                hasTransfers: segment.has_transfers ?? false
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
        let dependencies = try! AppDependencies(apikey: Constants.apiKey)
        let store = SearchStore(dependencies: dependencies)
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
