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
    var alarm: Int = 0
    let dateFormatter = DateFormatter()
    var alarmIsPlaying : Bool = false
    var gradientLayer : CAGradientLayer!
    
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        setUpPlayer()
        setBackground()
        updateTime()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.updateTime()
            self.checkAlarm()
        }
    }
    
    func setBackground() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blue.cgColor ,UIColor.black.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        let backgroundImageView = UIImageView(image: UIImage(named: "sunrise"))
        backgroundImageView.frame = view.bounds
        
        view.insertSubview(backgroundImageView, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarm = UserDefaults.standard.integer(forKey: "alarm")
        convertStoredAlarmToDate()
    }
    
    func getTimeAsString(time: Int? = Int(Date().timeIntervalSince1970)) -> String {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: Double(time!)))
        return dateStr
    }
    
    func checkAlarm() {
        if activateSwitch.isOn && getTimeAsString() == getTimeAsString(time: alarm) {
            if !self.player!.isPlaying {
                self.player?.play()
            }
            
            if snoozeBtn.isHidden {
                snoozeBtn.isHidden = false
            }
            alpha -= alpha == 0 ? 0 : 0.01
            gradientLayer.colors = [UIColor.blue.withAlphaComponent(alpha).cgColor ,UIColor.black.withAlphaComponent(alpha).cgColor]
            player?.volume += Float(alpha)
        }
    }
    
    func convertStoredAlarmToDate() {
        if alarm > 0 {
            alarmLbl.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(alarm)))
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
        alarm += 9 * 60
        snoozeBtn.isHidden = true
        player?.pause()
    }
    
    @IBAction func alarmSwitchChanged(_ sender: Any) {
//        if activateSwitch.isOn {
//            activateSwitch.thumbTintColor = UIColor.green
//        } else {
//            activateSwitch.thumbTintColor = UIColor.darkGray
//        }
        snoozeBtn.isHidden = true
        player?.stop()
        gradientLayer.colors = [UIColor.blue.withAlphaComponent(1.0).cgColor ,UIColor.black.withAlphaComponent(1.0).cgColor]
        alpha = 1
    }
    
    func setUpPlayer() {
        let path = Bundle.main.path(forResource: "deck-party", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        do {
            try player = AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = 10
        } catch {
            print(error)
        }
    }
    
}

