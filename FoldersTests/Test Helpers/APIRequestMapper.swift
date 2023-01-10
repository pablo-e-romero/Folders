//
//  APIRequestMapper.swift
//  FoldersTests
//
//  Created by Pablo Ezequiel Romero Giovannoni on 10/01/2023.
//

import Foundation
@testable import Folders

enum APIRequestMapperError: Error {
    case routeNotFound
}

enum APIResponseMock {
    case content(filename: String)
    case error(filename: String, statusCode: Int)
}

typealias APIRequestMapper = (URLRequest) throws -> APIResponseMock
typealias APIRequestMapperRoute = (httpMethod: String, urlPattern: String, response: APIResponseMock)

private func requestMapper(routes: [APIRequestMapperRoute]) -> APIRequestMapper {
    return { request in
        let route = routes.first {
            guard
                request.httpMethod == $0.httpMethod,
                let absoluteURL = request.url?.absoluteString,
                absoluteURL.matches(pattern: $0.urlPattern) else {
                return false
            }

            return true
        }

        guard let route = route else {
            throw APIRequestMapperError.routeNotFound
        }

        return route.response
    }
}

final class APIRequestMapperBuilder {
    private var routes = [APIRequestMapperRoute]()

    func append(httpMethod: HTTPMethod, urlPattern: String, response: APIResponseMock) -> Self {
        routes.append((httpMethod: httpMethod.name, urlPattern: urlPattern, response: response))
        return self
    }

    func build() -> APIRequestMapper {
        requestMapper(routes: routes)
    }
}
