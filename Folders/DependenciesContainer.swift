//
//  DependenciesContainer.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

final class DependenciesContainer {
    let apiService: APIServiceProtocol
    var basicAuthorization: BasicAuthentication

    init(apiService: APIServiceProtocol, basicAuthorization: BasicAuthentication) {
        self.apiService = apiService
        self.basicAuthorization = basicAuthorization
    }
}

extension DependenciesContainer {
    static var live: DependenciesContainer {
        let baseURL = URL(string: "http://163.172.147.216:8080")!
        let basicAuthorization = BasicAuthentication(
            credentials: (username: "noel", password: "foobar")
        )

        return .init(
            apiService: APIService(
                baseURL: baseURL,
                interceptors: [basicAuthorization.interceptor]
            ),
            basicAuthorization: basicAuthorization
        )
    }
}

protocol HasAPIService {
    var apiService: APIServiceProtocol { get }
}

extension DependenciesContainer: HasAPIService { }
