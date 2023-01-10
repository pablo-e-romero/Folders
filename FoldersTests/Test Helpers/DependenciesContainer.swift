//
//  DependenciesContainer.swift
//  FoldersTests
//
//  Created by Pablo Ezequiel Romero Giovannoni on 10/01/2023.
//

import Foundation
@testable import Folders

extension DependenciesContainer {
    static func mock(requestMapper: @escaping APIRequestMapper) -> DependenciesContainer {
        .init(
            apiService: APIServiceMock(
                baseURL: URL(string: "https://mock.com")!,
                requestMapper: requestMapper
            ),
            basicAuthorization: BasicAuthentication(),
            dataCache: EmptyCache<Data>().eraseToAnyCache(),
            itemsCache: EmptyCache<[Item]>().eraseToAnyCache()
        )
    }
}
