//
//  ItemsViewModel.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation
import Combine

protocol ItemsViewModelFactory {
    func newItemsViewModel(parentItem: ItemViewState) -> ItemsViewModel
}

extension DependenciesContainer: ItemsViewModelFactory {
    func newItemsViewModel(parentItem: ItemViewState) -> ItemsViewModel {
        ItemsViewModel(ctx: self, parentItem: parentItem)
    }
}

final class ItemsViewModel {
    typealias Context = ItemsRepositoryFactory
    private let itemsRepository: ItemsRepositoryProtocol
    private let parentItem: ItemViewState

    enum State {
        case initial(ItemsViewState)
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

    init(ctx: Context, parentItem: ItemViewState) {
        self.itemsRepository = ctx.newItemsRepository(parentItemId: parentItem.itemId)
        self.parentItem = parentItem
    }

    func viewDidLoad() {
        stateSubject.send(
            .initial(ItemsViewState(title: parentItem.name))
        )
        
        itemsRepository.itemsUpdatePublisher
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.stateSubject.send(.failure(error))
                }
            } receiveValue: { [weak self, parentItem] items in
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
