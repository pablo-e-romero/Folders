//
//  MessagePresenter.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import UIKit

protocol MessagePresenter {
    func presentError(_ error: Error)
    func presentError(_ message: String)
}

extension MessagePresenter where Self: UIViewController {
    func presentError(_ error: Error) {
        presentError(error.localizedDescription)
    }

    func presentError(_ message: String) {
        let alertController = UIAlertController(
            title: "Error".localized,
            message: message,
            preferredStyle: .alert)

        let okAction = UIAlertAction(
            title: "Ok".localized,
            style: .default)

        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
}

