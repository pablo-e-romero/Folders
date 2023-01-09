//
//  DiskCache.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import Foundation

final class DiskCache: Cache {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func set(_ value: Data, for key: String) {
        guard let url = url(from: key) else { return }
        try? value.write(to: url)
    }

    func get(for key: String) -> Data? {
        guard let url = url(from: key) else { return nil }
        return try? Data(contentsOf: url)
    }

    private func url(from key: String) -> URL? {
        guard var cachesUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        cachesUrl.appendPathComponent(key)
        return cachesUrl
    }

}
