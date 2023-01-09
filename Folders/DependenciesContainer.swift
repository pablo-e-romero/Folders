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
    let dataCache: AnyCache<Data>
    let itemsCache: AnyCache<[Item]>

    init(
        apiService: APIServiceProtocol,
        basicAuthorization: BasicAuthentication,
        dataCache: AnyCache<Data>,
        itemsCache: AnyCache<[Item]>
    ) {
        self.apiService = apiService
        self.basicAuthorization = basicAuthorization
        self.dataCache = dataCache
        self.itemsCache = itemsCache
    }
}

extension DependenciesContainer {
    static var live: DependenciesContainer {
        let baseURL = URL(string: "http://163.172.147.216:8080")!
        let basicAuthorization = BasicAuthentication()

        return .init(
            apiService: APIService(
                baseURL: baseURL,
                interceptors: [basicAuthorization.interceptor]
            ),
            basicAuthorization: basicAuthorization,
            dataCache: DiskCache().eraseToAnyCache(),
            itemsCache: MemoryCache<[Item]>().eraseToAnyCache()
        )
    }
}

protocol HasAPIService {
    var apiService: APIServiceProtocol { get }
}

extension DependenciesContainer: HasAPIService { }

protocol HasBasicAuthentication {
    var basicAuthorization: BasicAuthentication { get set }
}

extension DependenciesContainer: HasBasicAuthentication { }

protocol HasDataCacheService {
    var dataCache: AnyCache<Data> { get }
}

extension DependenciesContainer: HasDataCacheService { }

protocol HasItemsCacheService {
    var itemsCache: AnyCache<[Item]> { get }
}

extension DependenciesContainer: HasItemsCacheService { }
