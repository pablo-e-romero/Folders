//
//  DependenciesContainer.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

final class DependenciesContainer {
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
}

extension DependenciesContainer {
    static var live: DependenciesContainer {
        return .init(
            apiService: APIService(
                baseURL: URL(string: "http://163.172.147.216:8080")!
            )
        )
    }
}

protocol HasAPIService {
    var apiService: APIServiceProtocol { get }
}

extension DependenciesContainer: HasAPIService { }
