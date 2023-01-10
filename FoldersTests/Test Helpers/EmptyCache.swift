//
//  EmptyCache.swift
//  FoldersTests
//
//  Created by Pablo Ezequiel Romero Giovannoni on 10/01/2023.
//

import Foundation
@testable import Folders

struct EmptyCache<Value>: Cache {
    func set(_ value: Value, for key: String) { }
    func get(for key: String) -> Value? { nil }
}
