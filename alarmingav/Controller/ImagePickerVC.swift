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
    var imageSelected = false
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait,.portraitUpsideDown]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self as ImagePickerDelegate)
        
    }
    
    
    func setImage() {
        if let imgData = UserDefaults.standard.object(forKey: "bgImage") as? Data {
            let bgImage = NSKeyedUnarchiver.unarchiveObject(with: imgData) as! UIImage
            imageView.image = bgImage
            imageSelected = true
        } else {
            imageView.image = UIImage(named: "sunrise")
            imageSelected = false
        }
    }

    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    @IBAction func setBackgroundPressed(_ sender: Any) {
        if imageSelected == true {
            let imgData = NSKeyedArchiver.archivedData(withRootObject: self.imageView.image!)
            UserDefaults.standard.set(imgData, forKey: "bgImage")
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func resetImageButtonPressed(_ sender: Any) {
        print("resetting image")
        imageView.image = UIImage(named: "sunrise")
        UserDefaults.standard.removeObject(forKey: "bgImage")
        UserDefaults.standard.removeObject(forKey: "movie")
        imageSelected = false
    }
    
}

extension  ImagePickerVC: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        if image != nil {
            self.imageView.image = image
            UserDefaults.standard.removeObject(forKey: "movie")
            imageSelected = true
        }
    }
    
    func didSelectMovie(movie: NSURL?) {
        if movie != nil {
            //let movieData = NSKeyedArchiver.archivedData(withRootObject: movie!)
            saveVideoToDirectory(videoUrl: movie!)
            
            UserDefaults.standard.removeObject(forKey: "bgImage")
            self.imageView.image = grabFrameImage(url: movie!)
            imageSelected = true
        }
    }
    
    func saveVideoToDirectory(videoUrl: NSURL) {
        let videoData = NSData(contentsOf: videoUrl as URL)
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let newPath = path.appendingPathComponent("/backgroundVideo.mp4")
        do {
            try videoData?.write(to: newPath)
            let movieData = NSKeyedArchiver.archivedData(withRootObject: newPath)
            UserDefaults.standard.set(movieData, forKey: "movie")
            //print("movie url: ", newPath)
        } catch {
            print(error)
        }
    }
    
    func grabFrameImage(url: NSURL) -> UIImage {
        var frameImg : UIImage!
        let asset: AVAsset = AVAsset(url: url as URL)
        let assetImgGenerator : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerator.appliesPreferredTrackTransform = true
        assetImgGenerator.requestedTimeToleranceAfter = CMTime.zero
        assetImgGenerator.requestedTimeToleranceBefore = CMTime.zero
        do {
            let img  = try assetImgGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
             frameImg = UIImage(cgImage: img)
            return frameImg
        } catch {
            print("error")
            return frameImg
        }
        
        
    }
}
