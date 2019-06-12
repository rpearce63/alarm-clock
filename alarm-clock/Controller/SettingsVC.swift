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
    @IBOutlet weak var resetMusicButton: UIButton!
    @IBOutlet weak var resetImageButton: UIButton!
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait,.portraitUpsideDown]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
         let musicWithVideo = UserDefaults.standard.bool(forKey: "musicWithVideo")
        musicWithVideoSwitch.isOn = musicWithVideo
        let fadeSpeed = UserDefaults.standard.integer(forKey: "fadeSpeed")
        fadeSpeedSelector.selectedSegmentIndex = fadeSpeed
        setButtonStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setButtonStates()
    }
    
    func setButtonStates() {
        if UserDefaults.standard.object(forKey: "bgImage") == nil  &&
            UserDefaults.standard.object(forKey: "movie") == nil{
            print("no saved background image found")
            resetImageButton.setTitle("\u{2713}", for: .disabled)
            resetImageButton.isEnabled = false
        } else {
            print("saved image found")
            resetImageButton.setTitle("Reset", for: .normal)
            resetImageButton.isEnabled = true
        }
        
        if UserDefaults.standard.object(forKey: "playlist") == nil {
            print("no music set")
            resetMusicButton.setTitle("\u{2713}", for: .disabled)
            resetMusicButton.isEnabled = false
        } else {
            print("playlist found")
            resetMusicButton.setTitle("Reset", for: .normal)
            resetMusicButton.isEnabled = true
        }
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
        setButtonStates()
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
        setButtonStates()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
