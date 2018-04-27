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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let alarm = UserDefaults.standard.integer(forKey: "alarm")
        if alarm > 0 {
            datePicker.setDate(Date(timeIntervalSince1970: Double(alarm)), animated: true)
        }
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
        UserDefaults.standard.set(datePicker.date.timeIntervalSince1970, forKey: "alarm")
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        timeLbl.text = formatDate()
    }
    
}


