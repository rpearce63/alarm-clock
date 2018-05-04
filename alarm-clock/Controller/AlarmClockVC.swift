//
//  ViewController.swift
//  alarm-clock
//
//  Created by Rick Pearce on 4/27/18.
//  Copyright © 2018 Rick Pearce. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AlarmClockVC: UIViewController {

    @IBOutlet weak var clock: UILabel!
    @IBOutlet weak var activateSwitch: UISwitch!
    @IBOutlet weak var alarmLbl: UILabel!
    @IBOutlet weak var snoozeBtn: UIButton!
    
    var alpha : CGFloat = 1.0
    var alarm: String?
    let dateFormatter = DateFormatter()
    var alarmIsPlaying : Bool = false
    var gradientLayer : CAGradientLayer!
    
    var player : AVQueuePlayer = AudioService.instance.player!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        setBackground()
        setBackgroundFadeImage()
        updateTime()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.updateTime()
            self.checkAlarm()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarm = UserDefaults.standard.object(forKey: "alarm") as? String
        convertStoredAlarmToDate()
    }
    
    
    func setBackgroundGradientColors(alpha: CGFloat = 1.0) {
        let midnight = #colorLiteral(red: 0.01176470588, green: 0.1529411765, blue: 0.2274509804, alpha: 1) //#03273A
        gradientLayer.colors = [UIColor.black.withAlphaComponent(alpha).cgColor, midnight.withAlphaComponent(alpha).cgColor ,UIColor.black.withAlphaComponent(alpha).cgColor]
        gradientLayer.locations = [0.2, 0.5, 1]
    }
    
    func setBackground() {
        gradientLayer = CAGradientLayer()
        setBackgroundGradientColors()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func setBackgroundFadeImage() {
        let backgroundImageView = UIImageView(image: UIImage(named: "sunrise"))
        backgroundImageView.frame = view.bounds
        view.insertSubview(backgroundImageView, at: 0)
    }
    
    
    
    func getTimeAsString(time: Int? = Int(Date().timeIntervalSince1970)) -> String {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: Double(time!)))
        return dateStr
    }
    
    func checkAlarm() {
        if activateSwitch.isOn && (getTimeAsString() == alarm || alarmIsPlaying) {
            if !alarmIsPlaying {
                self.player.play()
                alarmIsPlaying = true
            }
            
            if snoozeBtn.isHidden {
                snoozeBtn.isHidden = false
            }
            if alpha > 0 {
                alpha -= 0.01
                setBackgroundGradientColors(alpha: alpha)
            }
            if player.volume < 1 {
                player.volume += 0.01
            }
            if UIScreen.main.brightness < 0.75 {
                UIScreen.main.brightness += 0.01
            }
        }
    }
    
    func convertStoredAlarmToDate() {
        if alarm != nil {
            alarmLbl.text = alarm
        } else {
            alarmLbl.text = "No Alarm Set"
        }
    }
    
    func updateTime() {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        let now = Date()
        clock.text = dateFormatter.string(from: now)
    }

    @IBAction func settingsBtnPressed(_ sender: Any) {
    }
    
    @IBAction func snoozeBtnPressed(_ sender: Any) {
        //alarm += 9 * 60
        snoozeBtn.isHidden = true
        player.pause()
        alarmIsPlaying = false
        UIScreen.main.brightness = 0.33
    }
    
    @IBAction func alarmSwitchChanged(_ sender: Any) {
        snoozeBtn.isHidden = true
        player.pause()
        alarmIsPlaying = false
        alpha = 1.0
        setBackgroundGradientColors(alpha: alpha)
        UIScreen.main.brightness = 0.33
    }
}

