//
//  APIServiceMock.swift
//  FoldersTests
//
//  Created by Pablo Ezequiel Romero Giovannoni on 10/01/2023.
//

import Foundation
import Combine
@testable import Folders

final class APIServiceMock: APIServiceProtocol {
    private let baseURL: URL
    private let requestMapper: APIRequestMapper

    init(baseURL: URL, requestMapper: @escaping APIRequestMapper) {
        self.baseURL = baseURL
        self.requestMapper = requestMapper
    }

    func execute<ResultType, ErrorType>(endpoint: APIEndpoint<ResultType, ErrorType>) -> AnyPublisher<ResultType, Error> {
        do {
            let urlRequest = endpoint.createURLRequest(baseURL: baseURL)
            let response = try requestMapper(urlRequest)

            switch response {
            case let .content(filename):
                let url = try ResourceManager.url(for: filename, extension: "json")
                let data = try Data(contentsOf: url)
                return Just(try endpoint.decodeResponse(data))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            case let .error(filename, statusCode):
                let url = try ResourceManager.url(for: filename, extension: "json")
                let data = try Data(contentsOf: url)
                let error = try endpoint.decodeError(data)
                return Fail(error: APIError.apiError(code: statusCode, message: error.message))
                    .eraseToAnyPublisher()
            }
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

}
