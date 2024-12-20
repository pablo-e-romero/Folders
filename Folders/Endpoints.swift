//
//  Endpoints.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    return decoder
}()

private let decoderISO8601: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

extension APIEndpoint where ResultType == Me, ErrorType == ErrorResponse {
    static var me: APIEndpoint {
        APIEndpoint(
            path: "/me",
            httpHeaders: [
                "Content-Type": "application/json"
            ],
            decoder: decoderISO8601
        )
    }
}

extension APIEndpoint where ResultType == [Item], ErrorType == ErrorResponse {
    static func items(containedBy itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)",
            httpHeaders: [
                "Content-Type": "application/json"
            ],
            decoder: decoder
        )
    }
}

extension APIEndpoint where ResultType == Item, ErrorType == ErrorResponse {
    static func uploadFile(name: String, data: Data, containedBy itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)",
            httpMethod: .post(data),
            httpHeaders: [
                "Content-Type": "application/octet-stream",
                "Content-Disposition": "attachment;filename*=utf-8''\(name).jpg"
            ],
            decoder: decoder
        )
    }

    static func createFolder(name: String, containedBy itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)",
            httpMethod: .post("{\"name\": \"\(name)\"}".data(using: .utf8)),
            httpHeaders: [
                "Content-Type": "application/json"
            ],
            decoder: decoder
        )
    }
}

extension APIEndpoint where ResultType == Void, ErrorType == ErrorResponse {
    static func deleteItem(with itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)",
            httpMethod: .delete,
            decodeResponse: { _ in return () },
            decodeError: { try decoder.decode(ErrorResponse.self, from: $0) }
        )
    }
}

extension APIEndpoint where ResultType == Data, ErrorType == ErrorResponse {
    static func downloadItem(with itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)/data",
            httpHeaders: [
                "Content-Type": "application/octet-stream"
            ],
            decodeResponse: { $0 },
            decodeError: { try decoder.decode(ErrorResponse.self, from: $0) }
        )
    }
}
