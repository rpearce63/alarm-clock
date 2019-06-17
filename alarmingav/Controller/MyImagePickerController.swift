//
//  MyImagePickerController.swift
//  alarm-clock
//
//  Created by Rick on 6/9/19.
//  Copyright © 2019 Rick Pearce. All rights reserved.
//

import UIKit
import MediaPlayer

class MyImagePickerController : UIImagePickerController {
    
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

//extension  ImagePickerVC: ImagePickerDelegate {
//    
//    func didSelect(image: UIImage?) {
//        if image != nil {
//            self.imageView.image = image
//            UserDefaults.standard.removeObject(forKey: "movie")
//            
//        }
//    }
//    
//    func didSelectMovie(movie: NSURL?) {
//        if movie != nil {
//            let movieData = NSKeyedArchiver.archivedData(withRootObject: movie!)
//            UserDefaults.standard.set(movieData, forKey: "movie")
//            UserDefaults.standard.removeObject(forKey: "bgImage")
//            self.imageView.image = grabFrameImage(url: movie!)
//        }
//    }
//    
//    func grabFrameImage(url: NSURL) -> UIImage {
//        var frameImg : UIImage!
//        let asset: AVAsset = AVAsset(url: url as URL)
//        let assetImgGenerator : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
//        assetImgGenerator.appliesPreferredTrackTransform = true
//        assetImgGenerator.requestedTimeToleranceAfter = CMTime.zero
//        assetImgGenerator.requestedTimeToleranceBefore = CMTime.zero
//        do {
//            //var error : NSError? = nil
//            //var time : CMTime = CMTimeMakeWithSeconds(0, preferredTimescale: 600)
//            let img  = try assetImgGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
//            frameImg = UIImage(cgImage: img)
//            return frameImg
//        } catch {
//            print("error")
//            return frameImg
//        }
//        
//        
//    }
//}
