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

    init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

extension APIService: APIServiceProtocol {

    func execute<ResultType>(endpoint: APIEndpoint<ResultType>) -> AnyPublisher<ResultType, Error> {
        let urlRequest = endpoint.createURLRequest(baseURL: baseURL)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, _ in
                try endpoint.decode(data)
            }
            .eraseToAnyPublisher()
    }

}
