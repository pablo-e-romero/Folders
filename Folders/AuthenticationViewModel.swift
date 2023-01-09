//
//  AuthenticationViewModel.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import Foundation
import Combine

protocol AuthenticationViewModelFactory {
    func newAuthenticationViewModel() -> AuthenticationViewModel
}

extension DependenciesContainer: AuthenticationViewModelFactory {
    func newAuthenticationViewModel() -> AuthenticationViewModel {
        AuthenticationViewModel(ctx: self)
    }
}

final class AuthenticationViewModel {
    typealias Context = HasAPIService & HasBasicAuthentication
    private let ctx: Context

    enum State {
        case initial
        case loading
        case authenciated(ItemViewState)
        case failure(Error)
    }

    var statePublisher: AnyPublisher<State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private let stateSubject = PassthroughSubject<State, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(ctx: Context) {
        self.ctx = ctx
    }

    func viewDidLoad() {
        stateSubject.send(.initial)
    }

    func authenticate(username: String, password: String) {
        stateSubject.send(.loading)

        ctx.basicAuthorization.credentials = (username: username, password: password)

        ctx.apiService.execute(endpoint: .me)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.ctx.basicAuthorization.credentials = nil
                    self?.stateSubject.send(.failure(error))
                }
            } receiveValue: { [weak self] me in
                self?.stateSubject.send(
                    .authenciated(ItemViewState(with: me.rootItem))
                )
            }
            .store(in: &cancellables)
    }

}

