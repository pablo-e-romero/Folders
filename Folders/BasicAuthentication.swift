//
//  BasicAuthentication.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

typealias Credentials = (username: String, password: String)

final class BasicAuthentication {
    var credentials: Credentials?

    var interceptor: Interceptor {
        .basicAuthentication { [weak self] in
            guard let credentials = self?.credentials else {
                assertionFailure("Credentials not set")
                return nil
            }
            return credentials
        }
    }

    init(credentials: Credentials? = nil) {
        self.credentials = credentials
    }
}

private func base64LoginString(from credentials: Credentials?) -> String {
    guard let credentials = credentials else { return "" }
    let string = "\(credentials.username):\(credentials.password)"
        .data(using: .utf8)?
        .base64EncodedString(options: [])
    guard let string = string else {
        assertionFailure("Invalid credentials conversion")
        return ""
    }
    return string
}

extension Interceptor {
    static func basicAuthentication(credentialsProvider: @escaping () -> Credentials?) -> Interceptor {
        Interceptor { urlRequest in
            var mutableUrlRequest = urlRequest
            mutableUrlRequest.setValue(
                "Basic \(base64LoginString(from: credentialsProvider()))",
                forHTTPHeaderField: "Authorization")
            return mutableUrlRequest
        }
    }
}
