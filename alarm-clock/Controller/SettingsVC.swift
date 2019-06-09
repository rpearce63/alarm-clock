//
//  SettingsVC.swift
//  alarm-clock
//
//  Created by Rick on 6/9/19.
//  Copyright © 2019 Rick Pearce. All rights reserved.
//

import UIKit
import MediaPlayer

class SettingsVC : UITableViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
    }
    
    
    @IBAction func selectMusicTouched(_ sender: UIButton) {
        let myMediaPickerVC = MyMediaPicker(mediaTypes: MPMediaType.music)
        //myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        //myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
    
//    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//        //print("Items selected: \(mediaItemCollection.items.count)")
//        AudioService.instance.setMusic(musicList: mediaItemCollection)
//        AudioService.instance.saveMusicList(musicList: mediaItemCollection)
//        mediaPicker.dismiss(animated: true, completion: nil)
//
//    }
//
//    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
//        mediaPicker.dismiss(animated: true, completion: nil)
//    }
    
    
    @IBAction func resetMusicTouched(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "playlist")
        UserDefaults.standard.removeObject(forKey: "movie")
        AudioService.instance.loadSavedMusic()
    }
    
    @IBAction func resetBackground(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "bgImage")
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
