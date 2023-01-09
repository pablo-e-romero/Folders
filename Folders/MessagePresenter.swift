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
    func presentInput(title: String?, message: String?, placeholder: String, completion: @escaping (String?) -> Void)
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

    func presentInput(title: String?, message: String?, placeholder: String, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)

        alertController.addTextField {
            $0.placeholder = placeholder
        }

        let okAction = UIAlertAction(
            title: "Ok".localized,
            style: .default) { [weak alertController] _ in
                guard
                    let textField = alertController?.textFields?.first as? UITextField,
                    let text = textField.text, !text.isEmpty
                else {
                    completion(nil)
                    return
                }

                completion(textField.text)
            }

        let cancelAction = UIAlertAction(
            title: "Cancel".localized,
            style: .cancel) { _ in
                completion(nil)
            }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

    }
}

