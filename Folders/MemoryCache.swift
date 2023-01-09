//
//  MemoryCache.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import Foundation

final class MemoryCache<Value>: Cache {
    private class ObjectWrapper: NSObject {
        let _value: Value

        init(value: Value) {
            self._value = value
        }
    }

    private let cache = NSCache<NSString, ObjectWrapper>()

    func set(_ value: Value, for key: String) {
        cache.setObject(.init(value: value), forKey: key as NSString)
    }

    func get(for key: String) -> Value? {
        cache.object(forKey: key as NSString)?._value
    }
}
