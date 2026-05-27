//
//  AppError.swift
//  TravelSchedule
//
//  Created by Павел Кузнецов on 26.05.2026.
//

import Foundation
import OpenAPIRuntime

enum AppError: Error, Equatable {
    case noInternet
    case server
}

enum ErrorMapper {
    static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }

        if let clientError = error as? ClientError {
            return map(clientError.underlyingError)
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .timedOut,
                 .dataNotAllowed,
                 .internationalRoamingOff,
                 .cannotConnectToHost,
                 .cannotFindHost:
                return .noInternet
            default:
                return .server
            }
        }

        return .server
    }
}
