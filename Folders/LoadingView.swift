//
//  LoadingView.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import UIKit

final class LoadingView: UIView {

    static func createAndShow(on parent: UIView) -> LoadingView {
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalToConstant: 66),
            loadingView.heightAnchor.constraint(equalToConstant: 66),
            loadingView.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            loadingView.centerXAnchor.constraint(equalTo: parent.centerXAnchor)
        ])
        return loadingView
    }

    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 10
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        activityIndicatorView.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

