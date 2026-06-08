//
//  CarrierViewModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 07.06.2026.
//

import Foundation
import Combine

@MainActor
final class CarrierViewModel: ObservableObject {
    @Published var details: CarrierDetails?
    @Published var isLoading: Bool = true
    @Published var hasError: Bool = false
    
    let carrier: Carrier
    private let networkClient: any NetworkClientProtocol
    
    init(carrier: Carrier, networkClient: any NetworkClientProtocol) {
        self.carrier = carrier
        self.networkClient = networkClient
    }
    
    func load() async {
        isLoading = true
        hasError = false
        defer { isLoading = false }
        
        do {
            let response = try await networkClient.getCarrierInfo(code: carrier.carrierCode ?? "")
            details = response.toCarrierDetails()
            hasError = false
        } catch {
            details = nil
            hasError = true
        }
    }
}

