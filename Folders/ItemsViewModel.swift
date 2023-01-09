//
//  ItemsViewModel.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation
import Combine

protocol ItemsViewModelFactory {
    func newItemsViewModel(parentItem: ItemViewState?) -> ItemsViewModel
}

extension DependenciesContainer: ItemsViewModelFactory {
    func newItemsViewModel(parentItem: ItemViewState?) -> ItemsViewModel {
        ItemsViewModel(ctx: self, parentItem: parentItem)
    }
}

final class ItemsViewModel {
    typealias Context = HasAPIService
    private let ctx: Context
    private var parentItem: ItemViewState?

    enum State {
        case initial
        case loading
        case uploading(progress: Float)
        case updated(ItemsViewState)
        case failure(Error)
    }

    var statePublisher: AnyPublisher<State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(ctx: Context, parentItem: ItemViewState?) {
        self.ctx = ctx
        self.parentItem = parentItem
    }

    func fetch() {
        stateSubject.send(.loading)

        guard let parentItem = parentItem else {
            ctx.apiService.execute(endpoint: .me)
                .sink { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.stateSubject.send(.failure(error))
                    }
                } receiveValue: { [weak self] me in
                    self?.parentItem = ItemViewState(with: me.rootItem)
                    self?.fetch()
                }
                .store(in: &cancellables)
            return
        }

        ctx.apiService.execute(endpoint: .items(containedBy: parentItem.itemId))
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.stateSubject.send(.failure(error))
                }
            } receiveValue: { [weak self] items in
                self?.stateSubject.send(
                    .updated(ItemsViewState(
                        title: parentItem.name,
                        items: items.map(ItemViewState.init(with:))))
                )
            }
            .store(in: &cancellables)
    }

    func uploadFile(data: Data) {

    }

    func createFolder(name: String) {

    }

}
