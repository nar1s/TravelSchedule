//
//  CarrierDetailsModel.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 07.06.2026.
//

struct CarrierDetails: Equatable, Sendable {
    let email: String
    let phone: String
    
    var hasAnyInfo: Bool {
        !email.isEmpty || !phone.isEmpty
    }
}
