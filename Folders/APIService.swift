//
//  APIService.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

import Combine

protocol APIServiceProtocol {
    func execute<ResultType>(endpoint: APIEndpoint<ResultType>) -> AnyPublisher<ResultType, Error>
}

final class APIService {
    private let baseURL: URL
    private let interceptors: [Interceptor]?

    init(baseURL: URL, interceptors: [Interceptor]? = nil) {
        self.baseURL = baseURL
        self.interceptors = interceptors
    }
}

extension APIService: APIServiceProtocol {

    func execute<ResultType>(endpoint: APIEndpoint<ResultType>) -> AnyPublisher<ResultType, Error> {

        let urlRequest = interceptors.map { interceptors in
            interceptors.reduce(endpoint.createURLRequest(baseURL: baseURL)) { partialResult, interceptor in
                interceptor.apply(partialResult)
            }
        } ?? endpoint.createURLRequest(baseURL: baseURL)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, _ in
                try endpoint.decode(data)
            }
            .eraseToAnyPublisher()
    }

}
