//
//  CarrierViewModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 07.06.2026.
//

import Foundation
import Combine

enum CarrierState: Equatable {
    case loading
    case loaded(CarrierDetails)
    case failed
}

@MainActor
final class CarrierViewModel: ObservableObject {
    
    @Published private(set) var state: CarrierState = .loading
    
    private let carrier: Carrier
    private let networkClient: any NetworkClientProtocol
    
    init(carrier: Carrier, networkClient: any NetworkClientProtocol) {
        self.carrier = carrier
        self.networkClient = networkClient
    }
    
    func load() async {
        state = .loading
        do {
            let details = try await fetchDetails()
            state = .loaded(details)
        } catch {
            state = .failed
        }
    }
    
    private func fetchDetails() async throws -> CarrierDetails {
        guard let code = carrier.carrierCode, !code.isEmpty else {
            return CarrierDetails(email: "", phone: "")
        }
        
        let response = try await networkClient.getCarrierInfo(code: code)
        
        let email = response.carrier?.email ?? ""
        let phone = response.carrier?.phone ?? ""
        return CarrierDetails(email: email, phone: phone)
    }
}

