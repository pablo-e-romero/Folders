//
//  ItemsRepository.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation
import Combine

protocol ItemsRepositoryProtocol {
    var itemsUpdatePublisher: AnyPublisher<[Item], Never> { get }

    func items() -> AnyPublisher<[Item], Error>
    func uploadFile(name: String, data: Data) -> AnyPublisher<Void, Error>
    func createFolder(name: String) -> AnyPublisher<Void, Error>
    func deleteItem(with itemId: String) -> AnyPublisher<Void, Error>
}

protocol ItemsRepositoryFactory {
    func newItemsRepository(parentItemId: String) -> ItemsRepositoryProtocol
}

extension DependenciesContainer: ItemsRepositoryFactory {
    func newItemsRepository(parentItemId: String) -> ItemsRepositoryProtocol {
        ItemsRepository(context: self, parentItemId: parentItemId)
    }
}

final class ItemsRepository: ItemsRepositoryProtocol {
    typealias Context = HasDataCacheService & HasItemsCacheService & HasAPIService
    private let ctx: Context

    private let parentItemId: String
    private var currentItems = [Item]()

    var itemsUpdatePublisher: AnyPublisher<[Item], Never> {
        itemsUpdateSubject.eraseToAnyPublisher()
    }

    private var itemsUpdateSubject = PassthroughSubject<[Item], Never>()
    private var cancellables = Set<AnyCancellable>()

    init(context: Context, parentItemId: String) {
        self.ctx = context
        self.parentItemId = parentItemId
    }

    func items() -> AnyPublisher<[Item], Error> {
        let cachePublisher = ctx.itemsCache.publisher(for: parentItemId)
            .setFailureType(to: Error.self)
            .compactMap { $0 }
            .eraseToAnyPublisher()

        let remotePublisher = ctx.apiService.execute(endpoint: .items(containedBy: parentItemId))
            .handleEvents(receiveOutput: { [weak self] items in
                guard let self = self else { return }
                self.currentItems = items
                self.ctx.itemsCache.set(self.currentItems, for: self.parentItemId)
            })
            .eraseToAnyPublisher()

        return Publishers.Merge(cachePublisher, remotePublisher).eraseToAnyPublisher()
    }

    func uploadFile(name: String, data: Data) -> AnyPublisher<Void, Error> {
        ctx.apiService.execute(endpoint: .uploadFile(name: name, data: data, containedBy: parentItemId))
            .handleEvents(receiveOutput: { [weak self] item in
                guard let self = self else { return }
                self.currentItems.append(item)
                self.ctx.itemsCache.set(self.currentItems, for: self.parentItemId)
                self.itemsUpdateSubject.send(self.currentItems)
            })
            .map { _ in return () }
            .eraseToAnyPublisher()
    }

    func createFolder(name: String) -> AnyPublisher<Void, Error> {
        ctx.apiService.execute(endpoint: .createFolder(name: name, containedBy: parentItemId))
            .handleEvents(receiveOutput: { [weak self] item in
                guard let self = self else { return }
                self.currentItems.append(item)
                self.ctx.itemsCache.set(self.currentItems, for: self.parentItemId)
                self.itemsUpdateSubject.send(self.currentItems)
            })
            .map { _ in return () }
            .eraseToAnyPublisher()
    }

    func deleteItem(with itemId: String) -> AnyPublisher<Void, Error> {
        ctx.apiService.execute(endpoint: .deleteItem(with: itemId))
            .handleEvents(receiveCompletion: { [weak self] completion in
                guard case .finished = completion, let self = self else { return }
                self.currentItems.removeAll(where: { $0.id == itemId })
                self.ctx.itemsCache.set(self.currentItems, for: self.parentItemId)
                self.itemsUpdateSubject.send(self.currentItems)
            })
            .map { _ in return () }
            .eraseToAnyPublisher()
    }

}
