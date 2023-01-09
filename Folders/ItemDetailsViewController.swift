//
//  ItemDetailsViewController.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import UIKit
import Combine

final class ItemDetailsViewController: UIViewController, MessagePresenter {
    private var contentView: UIView?
    private var loadingView: LoadingView?
    private let viewModel: ItemDetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ItemDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSate in
                guard let self = self else { return }
                switch newSate {
                case let .initial(viewState):
                    self.update(with: viewState)
                case .loading:
                    self.showLoading()
                case let .updated(viewState):
                    self.removeLoading()
                    self.update(with: viewState)
                case let .failure(error):
                    self.removeLoading()
                    self.presentError(error)
                }
            }
            .store(in: &cancellables)

        viewModel.viewDidLoad()
        viewModel.fetch()
    }

    private func update(with viewState: ItemDetailsViewState) {
        title = viewState.title
        removeContent()

        // TODO: we can add more cases as we support more content types
        switch viewState.content {
        case let .image(content): present(image: content)
        case .notSupported: self.presentError("Content not supported yet".localized)
        case .none: break
        }
    }

    private func present(image: UIImage) {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        imageView.image = image
    }

    private func removeContent() {
        contentView?.removeFromSuperview()
        contentView = nil
    }

    private func showLoading() {
        guard loadingView == nil else { return }
        loadingView = LoadingView.createAndShow(on: self.view)
    }

    private func removeLoading() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }

}
