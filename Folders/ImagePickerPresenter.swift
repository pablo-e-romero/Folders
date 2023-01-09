//
//  ImagePickerPresenter.swift
//  Folders
//
//  Created by Pablo Ezequiel Romero Giovannoni on 09/01/2023.
//

import UIKit
import PhotosUI

enum ImagePickerSource {
    case photoLibrary
    case camera
}

protocol ImagePickerPresenter {
    func presentImagePicker(sourceType: ImagePickerSource, completion: @escaping (Data?) -> Void)
}

private struct AssociatedKeys {
    static var ImagePicker = "ImagePicker"
}

extension ImagePickerPresenter where Self: UIViewController {

    private var imagePicker: ImagePicker? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ImagePicker) as? ImagePicker
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ImagePicker, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func presentImagePicker(sourceType: ImagePickerSource, completion: @escaping (Data?) -> Void) {
        switch sourceType {
        case .camera:
            self.imagePicker = CameraPicker(parentViewController: self)
        case .photoLibrary:
            self.imagePicker = PhotoLibraryPicker(parentViewController: self)
        }

        imagePicker?.completionHandler = { [weak self] data in
            DispatchQueue.main.async {
                completion(data)
            }
            self?.imagePicker = nil
        }
    }

}

protocol ImagePicker {
    var completionHandler: ((Data?) -> Void)? { get set }
}

final class CameraPicker: NSObject, ImagePicker, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var completionHandler: ((Data?) -> Void)?

    init(parentViewController: UIViewController) {
        super.init()
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        parentViewController.present(vc, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        picker.dismiss(animated: true) { [weak self] in
            self?.completionHandler?(image?.jpegData(compressionQuality: 0.5))
        }
    }
}

final class PhotoLibraryPicker: ImagePicker, PHPickerViewControllerDelegate {
    var completionHandler: ((Data?) -> Void)?

    init(parentViewController: UIViewController) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        let vc = PHPickerViewController(configuration: configuration)
        vc.delegate = self
        parentViewController.present(vc, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProviders = results.map(\.itemProvider)
        picker.dismiss(animated: true) { [weak self] in
            for item in itemProviders {
                if item.canLoadObject(ofClass: UIImage.self) {
                    item.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                        let image = image as? UIImage
                        self?.completionHandler?(image?.jpegData(compressionQuality: 0.5))
                    }
                }
            }
        }
    }

}
