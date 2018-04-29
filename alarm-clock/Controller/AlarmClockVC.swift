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
    var alarmIsRinging : Bool = false
    var red : CGFloat = 0
    var green : CGFloat = 0
    var blue : CGFloat = 0
    var gradientLayer : CAGradientLayer!
    
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.black.cgColor]
        //gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        //gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
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
            self.player?.play()
            if snoozeBtn.isHidden {
                snoozeBtn.isHidden = false
            }
            alpha -= alpha == 0 ? 0 : 0.02
            gradientLayer.colors = [UIColor.blue.withAlphaComponent(alpha).cgColor ,UIColor.black.withAlphaComponent(alpha).cgColor]
//            red += red >= 1 ? 0 : 00.001
//            green += green >= 1 ? 0 : 0.001
//            blue += blue >= 1 ? 0 : 0.001
//            view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
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
        alarm += 1 * 60
        snoozeBtn.isHidden = true
        player?.pause()
    }
    
    @IBAction func alarmSwitchChanged(_ sender: Any) {
        snoozeBtn.isHidden = true
        player?.stop()
    }
    
    func setUpPlayer() {
        let path = Bundle.main.path(forResource: "deck-party", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        do {
            try player = AVAudioPlayer(contentsOf: url)
        } catch {
            print(error)
        }
    }
    
}

