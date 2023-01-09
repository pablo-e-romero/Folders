//
//  AppCoordinator.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import UIKit

final class AppCoordinator: Coordinator {
    typealias Context = ItemsViewModelFactory & ItemDetailsViewModelFactory & AuthenticationViewModelFactory
    private let ctx: Context

    private let navController: UINavigationController

    init(navController: UINavigationController, context: Context) {
        self.navController = navController
        self.ctx = context
    }

    func start(animated: Bool) {
        showAuthenticationViewController(animated: animated)
    }

    private func showAuthenticationViewController(animated: Bool) {
        let vc = AuthenticationViewController(
            viewModel: ctx.newAuthenticationViewModel()
        )

        vc.authenticatedCallback = { [weak self] rootItem in
            self?.showItemsViewController(
                parentItem: rootItem,
                isRoot: true,
                animated: false)
        }

        navController.setViewControllers([vc], animated: animated)
    }

    private func showItemsViewController(parentItem: ItemViewState, isRoot: Bool, animated: Bool) {
        let vc = ItemsViewController(
            viewModel: ctx.newItemsViewModel(parentItem: parentItem)
        )

        vc.showChildItemCallback = { [weak self] item in
            if item.isDir {
                self?.showItemsViewController(
                    parentItem: item,
                    isRoot: false,
                    animated: true)
            } else {
                self?.showItemDetailsViewController(
                    with: item,
                    animated: true)
            }
        }

        if isRoot {
            navController.setViewControllers([vc], animated: animated)
        } else {
            navController.pushViewController(vc, animated: animated)
        }
    }

    private func showItemDetailsViewController(with item: ItemViewState, animated: Bool) {
        let vc = ItemDetailsViewController(
            viewModel: ctx.newItemDetailsViewModel(item: item)
        )
        navController.pushViewController(vc, animated: animated)
    }

}
