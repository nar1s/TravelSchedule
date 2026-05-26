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

    @ObservationIgnored
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
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
