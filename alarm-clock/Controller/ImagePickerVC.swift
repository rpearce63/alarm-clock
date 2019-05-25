//
//  ImagePickerVC.swift
//  alarm-clock
//
//  Created by Rick on 5/25/19.
//  Copyright © 2019 Rick Pearce. All rights reserved.
//

import UIKit

class ImagePickerVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self as ImagePickerDelegate)
        if let imgData = UserDefaults.standard.object(forKey: "bgImage") as? Data {
            let bgImage = NSKeyedUnarchiver.unarchiveObject(with: imgData) as! UIImage
            imageView.image = bgImage
        } else {
            imageView.image = UIImage(named: "sunrise")
        }
    }
    
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    @IBAction func setBackgroundPressed(_ sender: Any) {
        
        let imgData = NSKeyedArchiver.archivedData(withRootObject: self.imageView.image!)
        UserDefaults.standard.set(imgData, forKey: "bgImage")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func resetImage(_ sender: Any) {
        imageView.image = UIImage(named: "sunrise")
        UserDefaults.standard.removeObject(forKey: "bgImage")
    }
    
}

extension  ImagePickerVC: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.imageView.image = image
    }
}
