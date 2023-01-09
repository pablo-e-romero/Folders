//
//  ItemDataRepository.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import Foundation
import Combine

protocol ItemDataRepositoryProtocol {
    func itemData(with itemId: String) -> AnyPublisher<Data, Error>
}

protocol ItemDataRepositoryFactory {
    func newItemDataRepository() -> ItemDataRepositoryProtocol
}

extension DependenciesContainer: ItemDataRepositoryFactory {
    func newItemDataRepository() -> ItemDataRepositoryProtocol {
        ItemDataRepository(context: self)
    }
}

final class ItemDataRepository: ItemDataRepositoryProtocol {
    typealias Context = HasDataCacheService & HasItemsCacheService & HasAPIService
    private let ctx: Context

    init(context: Context) {
        self.ctx = context
    }

    func itemData(with itemId: String) -> AnyPublisher<Data, Error> {
        ctx.dataCache.publisher(for: itemId)
            .flatMap { [weak self] (data: Data?) -> AnyPublisher<Data, Error> in
                guard let self = self else { return Empty(outputType: Data.self, failureType: Error.self).eraseToAnyPublisher() }
                if let data = data {
                    return Just(data)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return self.ctx.apiService.execute(endpoint: .downloadItem(with: itemId))
                        .handleEvents(receiveOutput: { data in
                            self.ctx.dataCache.set(data, for: itemId)
                        })
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

}
