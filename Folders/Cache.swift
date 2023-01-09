//
//  Cache.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import Foundation
import Combine

protocol Cache {
    associatedtype Value

    func set(_ value: Value, for key: String)
    func get(for key: String) -> Value?
}

extension Cache {
    func publisher(for key: String) -> AnyPublisher<Value?, Never> {
        Future<Value?, Never> { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                promise(.success(get(for: key)))
            }
        }
        .eraseToAnyPublisher()
    }
}

struct AnyCache<Value>: Cache {
    private let _get: (String) -> Value?
    private let _set: (Value, String) -> Void

    init(
        get: @escaping (String) -> Value?,
        set: @escaping (Value, String) -> Void
    ) {
        self._get = get
        self._set = set
    }

    func set(_ value: Value, for key: String) {
        self._set(value, key)
    }

    func get(for key: String) -> Value? {
        return self._get(key)
    }
}

extension Cache {
    func eraseToAnyCache() -> AnyCache<Value> {
        AnyCache(
            get: self.get(for:),
            set: self.set(_:for:)
        )
    }
}
