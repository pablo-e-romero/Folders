//
//  HTTPMethod.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

public enum HTTPMethod {
    case get
    case post(Data?)
    case put(Data?)
    case patch
    case delete
    case head
}

public extension HTTPMethod {
    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .patch: return "PATCH"
        case .delete: return "DELETE"
        case .head: return "HEAD"
        }
    }

    var body: Data? {
        switch self {
        case .get, .patch, .delete, .head: return nil
        case let .post(data): return data
        case let .put(data): return data
        }
    }
}
