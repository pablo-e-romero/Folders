//
//  APIError.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

enum APIError: Error {
    case apiError(code: Int, message: String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .apiError(code, message):
            return "\(message) (\(code))"
        }
    }
}
