//
//  ItemCell.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import UIKit

class ItemCell: UITableViewCell {
    
    static var cellIdentifer: String {
        String(describing: ItemCell.self)
    }

    var item: ItemViewState? {
        didSet {
            var content = defaultContentConfiguration()
            content.image = item.flatMap { UIImage(systemName: $0.imageSystemName) }
            content.text = item?.name
            content.secondaryText = item?.details
            content.secondaryTextProperties.color = .secondaryLabel
            contentConfiguration = content
        }
    }

}
