//
//  MockData.swift
//  FoldersTests
//
//  Created by Pablo Ezequiel Romero Giovannoni on 10/01/2023.
//

import Foundation
@testable import Folders

enum MockData {
    static let parentItem = Item(
        id: "37678569f292d88ba1abd9c583fa99c2bc2d0650",
        parentId: "4b8e41fd4a6a89712f15bbf102421b9338cfab11",
        isDir: true,
        modificationDate: Date(),
        name: "peloncho",
        size: nil,
        contentType: nil
    )

    static let parentItemViewState = ItemViewState(with: MockData.parentItem)
}
