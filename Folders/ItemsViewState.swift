//
//  ItemsViewState.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import Foundation

struct ItemsViewState {
    let title: String
    let items: [ItemViewState]
}

extension ItemsViewState {
    init(title: String) {
        self.title = title
        self.items = []
    }
}

struct ItemViewState {
    enum ContentGroupType {
        case audio
        case image
        case text
        case video
        case unknown
    }

    let itemId: String
    let isDir: Bool
    let imageSystemName: String
    let name: String
    let size: String?
    let modifiedAt: String?
    let contentGroupType: ContentGroupType?
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
        contentGroupType = model.contentType?.groupType
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

    var groupType: ItemViewState.ContentGroupType {
        switch self {
        case .audioMPEG, .audioWMA, .audioRealAudio, .audioWAV: return .audio
        case .imageGIF, .imageJPEG, .imagePNG, .imageTIFF, .imageVNDMicrosoftIcon, .imageXIcon, .imageVNDDjvu, .imageSVGXML: return .image
        case .textCSS, .textCSV, .textHTML, .textJavascriot, .textPlan, .textXML: return .text
        case .videoMPEG, .videoMP4, .videoQuicktime, .videoXMSWMV, .videoXMSVideo, .videoXFLV, .videoWEBM: return .video
        default: return .unknown
        }
    }
}
