//
//  ItemDetailsViewState.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import UIKit

struct ItemDetailsViewState {
    // TODO: we can add more cases as we support more content types
    enum Content {
        case image(UIImage)
        case notSupported
    }

    let title: String
    let content: Content?
}

extension ItemDetailsViewState {
    init(title: String) {
        self.title = title
        self.content = nil
    }
}
