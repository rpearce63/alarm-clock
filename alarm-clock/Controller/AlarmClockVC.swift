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
    
    var alarm: Int = 0
    let dateFormatter = DateFormatter()
    var alarmIsRinging : Bool = false
    var red : CGFloat = 0
    var green : CGFloat = 0
    var blue : CGFloat = 0
    
//    var alarmMusic : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let path = Bundle.main.path(forResource: "deck-party", ofType: "mp3")
//        let url = URL(fileURLWithPath: path!)
//        do {
//            try alarmMusic = AVAudioPlayer(contentsOf: url)
//        } catch {
//            print(error)
//        }
        setBackground()
    }
    
    func setBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blue, UIColor.black]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.addSublayer(gradientLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarm = UserDefaults.standard.integer(forKey: "alarm")
        convertStoredAlarmToDate()
        updateTime()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.updateTime()
        
            self.checkAlarm()
        }
        
    }
    
    func getTimeAsString(time: Int? = Int(Date().timeIntervalSince1970)) -> String {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: Double(time!)))
        return dateStr
    }
    
    func checkAlarm() {
        if activateSwitch.isOn && getTimeAsString() == getTimeAsString(time: alarm) {
            AudioService.instance.player().play()
            if snoozeBtn.isHidden {
                snoozeBtn.isHidden = false
            }
            red += red >= 1 ? 0 : 00.001
            green += green >= 1 ? 0 : 0.001
            blue += blue >= 1 ? 0 : 0.001
            view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
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
        AudioService.instance.player().pause()
    }
    
    @IBAction func alarmSwitchChanged(_ sender: Any) {
        snoozeBtn.isHidden = true
        AudioService.instance.player().stop()
    }
    
}

