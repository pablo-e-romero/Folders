//
//  APIEndpoint.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

struct APIEndpoint<ResultType> {
    private let path: String
    private let httpMethod: HTTPMethod
    private let queryParameters: [String: CustomStringConvertible]?
    private let httpHeaders: [String: CustomStringConvertible]?
    let decode: (Data) throws -> ResultType

    init(
        path: String,
        httpMethod: HTTPMethod = .get,
        queryParameters: [String: CustomStringConvertible]? = nil,
        httpHeaders: [String: CustomStringConvertible]? = nil,
        decode: @escaping (Data) throws -> ResultType
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.queryParameters = queryParameters
        self.httpHeaders = httpHeaders
        self.decode = decode
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

extension APIEndpoint where ResultType: Decodable {
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
            decode: { try decoder.decode(ResultType.self, from: $0) } )
    }
}
