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
    
    @IBOutlet weak var musicWithVideoSwitch: UISwitch!
    @IBOutlet weak var fadeSpeedSelector: UISegmentedControl!
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
         let musicWithVideo = UserDefaults.standard.bool(forKey: "musicWithVideo")
        musicWithVideoSwitch.isOn = musicWithVideo
        let fadeSpeed = UserDefaults.standard.integer(forKey: "fadeSpeed")
        fadeSpeedSelector.selectedSegmentIndex = fadeSpeed 
    }
    
    
    @IBAction func selectMusicTouched(_ sender: UIButton) {
        let myMediaPickerVC = MyMediaPicker(mediaTypes: MPMediaType.music)
        //myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        //myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
    
    
    @IBAction func resetMusicTouched(_ sender: UIButton) {
        print("resetting music")
        UserDefaults.standard.removeObject(forKey: "playlist")
        //AudioService.instance.loadSavedMusic()
    }
    
    @IBAction func musicAndVideoChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "musicWithVideo")
    }
    
    
    @IBAction func fadeSpeedChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "fadeSpeed")
    }
    
    @IBAction func resetBackground(_ sender: UIButton) {
        print("resetting background image")
        UserDefaults.standard.removeObject(forKey: "bgImage")
        UserDefaults.standard.removeObject(forKey: "movie")
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
