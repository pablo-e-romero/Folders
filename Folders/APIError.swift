//
//  APIError.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

protocol APIErrorProtocol {
    var message: String? { get }
}

enum APIError: Error {
    case apiError(code: Int, message: String?)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .apiError(statusCode, message):
            if let message = message {
                return "\(message) (\(statusCode))."
            } else {
                return "\("Status code".localized) \(statusCode)."
            }
        }
    }
}
