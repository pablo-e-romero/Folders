//
//  Model.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 08/01/2023.
//

import Foundation

struct ErrorResponse: Decodable {
    let error: String?
}

extension ErrorResponse: APIErrorProtocol {
    var message: String? { error }
}

struct Me: Decodable {
    let firstName: String
    let lastName: String
    let rootItem: Item
}

struct Item: Decodable {
    let id: String
    let parentId: String
    let isDir: Bool
    let modificationDate: Date
    let name: String
    let size: Int64?
    let contentType: ContentType?
}

enum ContentType: String, Decodable {
    case applicationJavaArchive = "application/java-archive"
    case applicationEDIX12 = "application/EDI-X12"
    case applicationEDIFACT = "application/EDIFACT"
    case applicationJavascript = "application/javascript"
    case applicationOctetStream = "application/octet-stream"
    case applicationOGG = "application/ogg"
    case applicationPDF = "application/pdf"
    case applicationXHTML = "application/xhtml+xml"
    case applicationCShockwaveFlash = "application/x-shockwave-flash"
    case applicationJSON = "application/json"
    case applicationLDJSON = "application/ld+json"
    case applicationXML = "application/xml"
    case applicationZIP = "application/zip"
    case audioMPEG = "audio/mpeg"
    case audioWMA = "audio/x-ms-wma"
    case audioRealAudio = "audio/vnd.rn-realaudio"
    case audioWAV = "audio/x-wav"
    case imageGIF = "image/gif"
    case imageJPEG = "image/jpeg"
    case imagePNG = "image/png"
    case imageTIFF = "image/tiff"
    case imageVNDMicrosoftIcon = "image/vnd.microsoft.icon"
    case imageXIcon = "image/x-icon"
    case imageVNDDjvu = "image/vnd.djvu"
    case imageSVGXML = "image/svg+xml"
    case textCSS = "text/css"
    case textCSV = "text/csv"
    case textHTML = "text/html"
    case textJavascriot = "text/javascript"
    case textPlan = "text/plain"
    case textXML = "text/xml"
    case videoMPEG = "video/mpeg"
    case videoMP4 = "video/mp4"
    case videoQuicktime = "video/quicktime"
    case videoXMSWMV = "video/x-ms-wmv"
    case videoXMSVideo = "video/x-msvideo"
    case videoXFLV = "video/x-flv"
    case videoWEBM = "video/webm"
}
