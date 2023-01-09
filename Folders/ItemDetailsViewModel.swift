//
//  ItemDetailsViewModel.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import UIKit
import Combine

protocol ItemDetailsViewModelFactory {
    func newItemDetailsViewModel(item: ItemViewState) -> ItemDetailsViewModel
}

extension DependenciesContainer: ItemDetailsViewModelFactory {
    func newItemDetailsViewModel(item: ItemViewState) -> ItemDetailsViewModel {
        ItemDetailsViewModel(ctx: self, item: item)
    }
}

enum ItemDetailsError: Error {
    case invalidContent
}

final class ItemDetailsViewModel {
    typealias Context = ItemDataRepositoryFactory
    private let itemDataRepository: ItemDataRepositoryProtocol
    private let item: ItemViewState

    enum State {
        case initial(ItemDetailsViewState)
        case loading
        case updated(ItemDetailsViewState)
        case failure(Error)
    }

    var statePublisher: AnyPublisher<State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(ctx: Context, item: ItemViewState) {
        self.itemDataRepository = ctx.newItemDataRepository()
        self.item = item
    }

    func viewDidLoad() {
        stateSubject.send(
            .initial(ItemDetailsViewState(title: item.name))
        )
    }

    func fetch() {
        stateSubject.send(.loading)

        itemDataRepository.itemData(with: item.itemId)
            .map { [weak self, item] data in
                self?.convert(data: data, contentGroupType: item.contentGroupType)
            }
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.stateSubject.send(.failure(error))
                }
            } receiveValue: { [weak self, item] content in
                self?.stateSubject.send(
                    .updated(ItemDetailsViewState(title: item.name, content: content))
                )
            }
            .store(in: &cancellables)
    }

    private func convert(data: Data, contentGroupType: ItemViewState.ContentGroupType?) -> ItemDetailsViewState.Content {
        switch contentGroupType {
        case .image: return UIImage(data: data).map(ItemDetailsViewState.Content.image) ?? .notSupported
        // TODO: here we have to do the right conversion for another content types
        case .audio, .text, .video, .unknown: return .notSupported
        case .none: return .notSupported
        }
    }
}
