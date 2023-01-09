//
//  ItemsCoordinator.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import UIKit

final class ItemsCoordinator: Coordinator {
    typealias Context = ItemsViewModelFactory
    private let ctx: Context

    private let navController: UINavigationController

    init(navController: UINavigationController, context: Context) {
        self.navController = navController
        self.ctx = context
    }

    func start(animated: Bool) {
        showItemsViewController(parentItem: nil, animated: animated)
    }

    private func showItemsViewController(parentItem: ItemViewState?, animated: Bool) {
        let vc = ItemsViewController(
            viewModel: ctx.newItemsViewModel(parentItem: parentItem)
        )

        vc.showChildItemCallback = { [weak self] item in
            if item.isDir {
                self?.showItemsViewController(
                    parentItem: item,
                    animated: animated)
            } else {
                self?.showItemDetailsViewController(
                    with: item,
                    animated: animated)
            }
        }
        navController.pushViewController(vc, animated: animated)
    }

    private func showItemDetailsViewController(with item: ItemViewState, animated: Bool) {
//        let vc = ItemDetailsViewController(
//            viewModel: ctx.newItemDetailsViewModel(itemId: itemId)
//        )
//        navController.pushViewController(vc, animated: animated)
    }

}
