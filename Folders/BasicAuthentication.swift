//
//  BasicAuthentication.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

typealias Credentials = (username: String, password: String)

struct BasicAuthentication {
    var credentials: Credentials

    var interceptor: Interceptor {
        .basicAuthentication { credentials }
    }

    init(credentials: Credentials) {
        self.credentials = credentials
    }
}

private func base64LoginString(from credentials: Credentials) -> String {
    let string = "\(credentials.username):\(credentials.password)"
        .data(using: .utf8)?
        .base64EncodedString(options: [])
    guard let string = string else {
        fatalError("Invalid credentials conversion")
    }
    return string
}

extension Interceptor {
    static func basicAuthentication(credentialsProvider: @escaping () -> Credentials) -> Interceptor {
        Interceptor { urlRequest in
            var mutableUrlRequest = urlRequest
            mutableUrlRequest.setValue(
                "Basic \(base64LoginString(from: credentialsProvider()))",
                forHTTPHeaderField: "Authorization")
            return mutableUrlRequest
        }
    }
}
