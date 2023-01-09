//
//  APIService.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

import Combine

protocol APIServiceProtocol {
    func execute<ResultType, ErrorType>(endpoint: APIEndpoint<ResultType, ErrorType>) -> AnyPublisher<ResultType, Error>
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

    func execute<ResultType, ErrorType>(endpoint: APIEndpoint<ResultType, ErrorType>) -> AnyPublisher<ResultType, Error> {

        let urlRequest = interceptors.map { interceptors in
            interceptors.reduce(endpoint.createURLRequest(baseURL: baseURL)) { partialResult, interceptor in
                interceptor.apply(partialResult)
            }
        } ?? endpoint.createURLRequest(baseURL: baseURL)

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200

                if 200..<300 ~= statusCode {
                    return try endpoint.decodeResponse(data)
                } else {
                    let errorResponse = try? endpoint.decodeError(data)
                    throw APIError.apiError(code: statusCode, message: errorResponse?.message)
                }
            }
            .eraseToAnyPublisher()
    }

}
