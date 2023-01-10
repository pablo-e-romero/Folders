//
//  ResourceManager.swift
//  FoldersTests
//
//  Created by Pablo Ezequiel Romero Giovannoni on 10/01/2023.
//

import Foundation

enum ResourceManagerError: Error {
    case fileNotFound
}

final class ResourceManager {
    static func url(for resource: String, extension: String) throws -> URL {
        guard let url = Bundle(for: Self.self).url(forResource: resource, withExtension: `extension`) else {
            throw ResourceManagerError.fileNotFound
        }

        return url
    }
}
