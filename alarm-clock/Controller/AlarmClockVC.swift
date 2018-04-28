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
    var alarmMusic : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "deck-party", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        do {
            try alarmMusic = AVAudioPlayer(contentsOf: url)
        } catch {
            print(error)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarm = UserDefaults.standard.integer(forKey: "alarm")
        convertStoredAlarmToDate()
        setTime()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.setTime()
        
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
            alarmMusic?.play()
            if snoozeBtn.isHidden {
                snoozeBtn.isHidden = false
            }
        }
    }
    
    func convertStoredAlarmToDate() {
        if alarm > 0 {
            alarmLbl.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(alarm)))
        } else {
            alarmLbl.text = "No Alarm Set"
        }
    }
    
    func setTime() {
        
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
        alarmMusic?.pause()
    }
    
    @IBAction func alarmSwitchChanged(_ sender: Any) {
        snoozeBtn.isHidden = true
        alarmMusic?.stop()
    }
    
}

