//
//  ItemsViewState.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import Foundation

struct ItemsViewState {
    let title: String
    let subtitle: String
    let items: [ItemViewState]
}

extension ItemsViewState {
    init(title: String, items: [ItemViewState]) {
        self.title = title
        let count = items.count
        self.subtitle = "\(count) \(count == 1 ? "item".localized : "items".localized)"
        self.items = items
    }
}

struct ItemViewState {
    let itemId: String
    let isDir: Bool
    let imageSystemName: String
    let name: String
    let size: String?
    let modifiedAt: String?
}

extension ItemViewState: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemId)
    }
}

private func formatSize(_ size: Int) -> String {
    "12 KB"
}

private func formatDate(_ date: Date) -> String {
    "123"
}

extension ItemViewState {
    init(with model: Item) {
        itemId = model.id
        isDir = model.isDir
        imageSystemName = model.isDir ? "folder" : model.contentType?.imageSystemName ?? "doc"
        name = model.name
        size = model.size.map(formatSize)
        modifiedAt = formatDate(model.modificationDate)
    }
}

extension ContentType {
    var imageSystemName: String {
        switch self {
        case .audioMPEG, .audioWMA, .audioRealAudio, .audioWAV: return "waveform"
        case .imageGIF, .imageJPEG, .imagePNG, .imageTIFF, .imageVNDMicrosoftIcon, .imageXIcon, .imageVNDDjvu, .imageSVGXML: return "photo"
        case .textCSS, .textCSV, .textHTML, .textJavascriot, .textPlan, .textXML: return "doc.text"
        case .videoMPEG, .videoMP4, .videoQuicktime, .videoXMSWMV, .videoXMSVideo, .videoXFLV, .videoWEBM: return "film"
        default: return "doc"
        }
    }
}
