//
//  AuthenticationViewController.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import UIKit
import Combine

final class AuthenticationViewController: UIViewController, MessagePresenter, LoadingViewPresenter {

    private let viewModel: AuthenticationViewModel
    private var cancellables = Set<AnyCancellable>()

    var authenticatedCallback: ((ItemViewState) -> Void)?

    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Autentication".localized
        view.backgroundColor = .systemBackground

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSate in
                guard let self = self else { return }
                switch newSate {
                case .initial:
                    break
                case .loading:
                    self.presentLoadingView()
                case let .authenciated(viewState):
                    self.removeLoadingView()
                    self.authenticatedCallback?(viewState)
                case let .failure(error):
                    self.removeLoadingView()
                    self.presentError(error)
                }
            }
            .store(in: &cancellables)

        viewModel.viewDidLoad()
        
        // TODO: create some UI to input these values
        viewModel.authenticate(username: "noel", password: "foobar")
    }

}

