//
//  ImagePickerVC.swift
//  alarm-clock
//
//  Created by Rick on 5/25/19.
//  Copyright © 2019 Rick Pearce. All rights reserved.
//

import UIKit
import MediaPlayer

class ImagePickerVC: UIViewController,  MPMediaPickerControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker: ImagePicker!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
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
    
    @IBAction func selectMusicButtonPressed(_ sender: UIButton) {
        
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        //print("Items selected: \(mediaItemCollection.items.count)")
        AudioService.instance.setMusic(musicList: mediaItemCollection)
        AudioService.instance.saveMusicList(musicList: mediaItemCollection)
        mediaPicker.dismiss(animated: true, completion: nil)
        
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
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
    @IBAction func resetImageAndMusic(_ sender: Any) {
        imageView.image = UIImage(named: "sunrise")
        UserDefaults.standard.removeObject(forKey: "bgImage")
        UserDefaults.standard.removeObject(forKey: "playlist")
    }
    
}

extension  ImagePickerVC: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        if image != nil {
            self.imageView.image = image
            
        }
    }
}
