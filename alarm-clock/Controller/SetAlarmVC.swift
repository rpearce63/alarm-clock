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
    var alarmList : [Date] = []
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait,.portraitUpsideDown]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        timeLbl.text = formatDate()
        
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

        alarmList.append(convertToBaseDate(datePicker.date))
        
        UserDefaults.standard.set(strAlarm, forKey: "alarm")
        UserDefaults.standard.set(alarmList, forKey: "alarms")
        dismiss(animated: true, completion: nil)
        
    }
    
    func convertToBaseDate(_ input: Date) -> Date {
        var baseDate = Date(timeIntervalSinceReferenceDate: 0)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: input)
        
        baseDate = Calendar.current.date(byAdding: timeComponents, to: baseDate)!
        
        return baseDate
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        
        timeLbl.text = formatDate()
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


