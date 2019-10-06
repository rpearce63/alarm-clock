//
//  ImagePicker.swift
//  alarm-clock
//
//  Created by Rick on 5/25/19.
//  Copyright © 2019 Rick Pearce. All rights reserved.
//

import UIKit

public protocol ImagePickerDelegate: class {
     func didSelect(image: UIImage?)
     func didSelectMovie(movie: NSURL?)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public  init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = MyUIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image", "public.movie"]
        
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo Library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelectMovie movie: NSURL?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelectMovie(movie: movie)
    }
    

}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.mediaType] as? String == "public.movie" {
            guard let movieUrl = info[.mediaURL] as? NSURL else {
                print("could not get movie")
                return
            }
            self.pickerController(picker, didSelectMovie: movieUrl)
            
        } else {
            guard let image = info[.editedImage] as? UIImage else {
                return self.pickerController(picker, didSelect: nil)
            }
            self.pickerController(picker, didSelect: image)
        }
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}

class MyUIImagePickerController : UIImagePickerController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}