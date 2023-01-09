//
//  APIEndpoint.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

struct APIEndpoint<ResultType, ErrorType: APIErrorProtocol> {
    private let path: String
    private let httpMethod: HTTPMethod
    private let queryParameters: [String: CustomStringConvertible]?
    private let httpHeaders: [String: CustomStringConvertible]?
    let decodeResponse: (Data) throws -> ResultType
    let decodeError: (Data) throws -> ErrorType

    init(
        path: String,
        httpMethod: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        httpHeaders: [String: CustomStringConvertible]? = nil,
        decodeResponse: @escaping (Data) throws -> ResultType,
        decodeError: @escaping (Data) throws -> ErrorType
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.queryParameters = queryParameters
        self.httpHeaders = httpHeaders
        self.decodeResponse = decodeResponse
        self.decodeError = decodeError
    }

    func createURLRequest(baseURL: URL) -> URLRequest {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            fatalError("Error initalizing URLBuilder")
        }

        urlComponents.path.append(path)

        let queryItems: [URLQueryItem]? = queryParameters
            .map { parameters in
                parameters.map { URLQueryItem(name: $0.key, value: $0.value.description) }
            }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            fatalError("Error buidling URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.name
        urlRequest.httpBody = httpMethod.body

        if let httpHeaders = httpHeaders {
            httpHeaders.forEach {
                urlRequest.setValue($0.value.description, forHTTPHeaderField: $0.key)
            }
        }

        return urlRequest
    }
}

extension APIEndpoint where ResultType: Decodable, ErrorType: Decodable {
    init(
        path: String,
        httpMethod: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        httpHeaders: [String: CustomStringConvertible]? = nil,
        decoder: JSONDecoder
    ) {
        self.init(
            path: path,
            httpMethod: httpMethod,
            queryParameters: queryParameters,
            httpHeaders: httpHeaders,
            decodeResponse: { try decoder.decode(ResultType.self, from: $0) },
            decodeError: { try decoder.decode(ErrorType.self, from: $0) }
        )
    }
}
