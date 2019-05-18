//
//  SettingsVC.swift
//  alarm-clock
//
//  Created by Rick Pearce on 4/27/18.
//  Copyright © 2018 Rick Pearce. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController  {
    

    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var timeLbl: UILabel!
    var alarms : [String] = []
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let alarms = UserDefaults.standard.array(forKey: "alarmList") as? [String] {
            self.alarms = alarms
        }
//        let alarm = UserDefaults.standard.integer(forKey: "alarm")
//        if alarm > 0 {
//            datePicker.setDate(Date(timeIntervalSince1970: Double(alarm)), animated: true)
//            timeLbl.text = formatDate()
//        }
        setBackground()
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
        //print(formatDate())
        //UserDefaults.standard.set(datePicker.date.timeIntervalSince1970, forKey: "alarm")
        alarms.append(formatDate())
        UserDefaults.standard.set(alarms, forKey: "alarmList")
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        timeLbl.text = formatDate()
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


