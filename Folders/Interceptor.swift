//
//  Interceptor.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

struct Interceptor {
    let apply: (URLRequest) -> URLRequest

    init(apply: @escaping (URLRequest) -> URLRequest) {
        self.apply = apply
    }
}
