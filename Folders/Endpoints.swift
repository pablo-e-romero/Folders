//
//  Endpoints.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()

extension APIEndpoint where ResultType == Me {
    static func me() -> APIEndpoint {
        APIEndpoint(
            path: "/me",
            httpHeaders: [
                "Content-Type": "application/json"
            ],
            decoder: decoder
        )
    }
}

extension APIEndpoint where ResultType == [Item] {
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

extension APIEndpoint where ResultType == Item {
    static func uploadFile(data: Data, containedBy itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)",
            httpMethod: .post(data),
            httpHeaders: [
                "Content-Type": "application/octet-stream",
                "Content-Disposition": "attachment;filename*=utf-8''picture.jpg"
            ],
            decoder: decoder
        )
    }

    static func createFolder(name: String, containedBy itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)",
            httpMethod: .post("{\"name\": \(name)}".data(using: .utf8)),
            httpHeaders: [
                "Content-Type": "application/json"
            ],
            decoder: decoder
        )
    }
}

extension APIEndpoint where ResultType == Void {
    static func deleteItem(with itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)",
            httpMethod: .delete,
            decode: { _ in return () }
        )
    }
}

extension APIEndpoint where ResultType == Data {
    static func downloadItem(with itemId: String) -> APIEndpoint {
        APIEndpoint(
            path: "/items/\(itemId)/data",
            httpHeaders: [
                "Content-Type": "application/octet-stream"
            ],
            decode: { $0 }
        )
    }
}