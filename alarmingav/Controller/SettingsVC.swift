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
    @IBOutlet weak var mwvHelpButton: UIButton!
    
    var alarmClockVC:AlarmClockVC?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait,.portraitUpsideDown]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        if let musicWithVideo = UserDefaults.standard.object(forKey: "musicWithVideo") {
            musicWithVideoSwitch.isOn = musicWithVideo as! Bool
        }
        if let fadeSpeed = UserDefaults.standard.object(forKey: "fadeSpeed") {
            fadeSpeedSelector.selectedSegmentIndex = fadeSpeed as! Int
        }
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
        UserDefaults.standard.removeObject(forKey: "bgImage")
        UserDefaults.standard.removeObject(forKey: "movie")
        setButtonStates()
    }
    
    @IBAction func musicWithVideoInfoButtonPressed(_ sender: UIButton) {
        displayInfoPopover(anchor: sender, content: Constants.MUSIC_WITH_VIDEO_HELP_TEXT)
        
    }
    
    @IBAction func fadeSpeedInfoButtonPressed(_ sender: UIButton) {
        displayInfoPopover(anchor: sender, content: Constants.FADE_SPEED_HELP_TEXT)
    }
    
    func displayInfoPopover(anchor: UIButton, content : String ) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? HelpInfoPopoverVC else { return }
        
        popVC.modalPresentationStyle = .popover
        
        let popOverVC = popVC.popoverPresentationController
        popOverVC?.delegate = (self as UIPopoverPresentationControllerDelegate)
        popOverVC?.sourceView = anchor
        popOverVC?.sourceRect = CGRect(x: anchor.bounds.midX, y: anchor.bounds.minY, width: 0, height: 0)
        popVC.preferredContentSize = CGSize(width: 250, height: 150)
        popVC.content = content
        self.present(popVC, animated: true)
    }
    
}

extension SettingsVC: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
