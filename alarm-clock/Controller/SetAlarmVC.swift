//
//  SettingsVC.swift
//  alarm-clock
//
//  Created by Rick Pearce on 4/27/18.
//  Copyright © 2018 Rick Pearce. All rights reserved.
//

import UIKit


class SetAlarmVC: UIViewController  {
    

    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var timeLbl: UILabel!
    //var alarms : [String] = []
    var alarmList : [Date] = []
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait,.portraitUpsideDown]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLbl.text = formatDate()
//        if let alarms = UserDefaults.standard.array(forKey: "alarmList") as? [String] {
//            self.alarms = alarms
//        }
        if let alarmList = UserDefaults.standard.array(forKey: "alarms") as? [Date] {
            self.alarmList = alarmList
        }

        //setBackground()
    }

    func setBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.cyan.cgColor ,UIColor.blue.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func formatDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        let strDate = dateFormatter.string(from: datePicker.date)
        
        return strDate
    }
    
    @IBAction func setAlarmBtnPressed(_ sender: Any) {
        let strAlarm = formatDate()
        //alarms.append(strAlarm)
        alarmList.append(datePicker.date)
        //UserDefaults.standard.set(alarms, forKey: "alarmList")
        UserDefaults.standard.set(strAlarm, forKey: "alarm")
        UserDefaults.standard.set(alarmList, forKey: "alarms")
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        timeLbl.text = formatDate()
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


