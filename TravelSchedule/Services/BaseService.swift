//
//  BaseService.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 25.05.2026.
//

import OpenAPIRuntime
import OpenAPIURLSession

class BaseService {
    let client: Client
    let apikey: String

    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
}
