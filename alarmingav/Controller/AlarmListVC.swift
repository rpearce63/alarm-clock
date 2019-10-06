//
//  AlarmListVC.swift
//  alarm-clock
//
//  Created by Helen Pearce on 5/3/18.
//  Copyright © 2018 Rick Pearce. All rights reserved.
//

import UIKit


class AlarmListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var alarmList: [Date] = []
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait,.portraitUpsideDown]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //setTableBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateAlarmList()
    }
    
    func updateAlarmList() {
        if let alarmList = UserDefaults.standard.array(forKey: "alarms") as? [Date] {
            self.alarmList = alarmList.sorted()
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(alarmList, forKey: "alarms")
    }

    @IBAction func unwindToAlarmList(segue: UIStoryboardSegue) {
        updateAlarmList()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        UserDefaults.standard.set(alarmList, forKey: "alarms")
    }
    
    func setTableBackground() {
        let background = UIView(frame: view.bounds)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.orange.cgColor, UIColor.yellow.cgColor]
        gradient.frame = background.bounds
        background.layer.insertSublayer(gradient, at: 0)
        
        tableView.backgroundView = background
    }

}

extension AlarmListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strAlarm = UserDefaults.standard.object(forKey: "alarm") as? String
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell") else { return UITableViewCell() }
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 24)
        cell.textLabel?.text = formatDate(date: alarmList[indexPath.row])
        if cell.textLabel?.text == strAlarm {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = #colorLiteral(red: 0.9188147187, green: 0.9188147187, blue: 0.9188147187, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            alarmList.remove(at: indexPath.row)
        }
        tableView.reloadData()
        if alarmList.count == 0 {
            UserDefaults.standard.removeObject(forKey: "alarm")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        for cell in tableView.visibleCells {
            if cell != selectedCell {
                cell.accessoryType = .none
            } else {
                if selectedCell?.accessoryType == .checkmark {
                    selectedCell?.accessoryType = .none
                    UserDefaults.standard.removeObject(forKey: "alarm")
                } else {
                    selectedCell?.accessoryType = .checkmark
                    UserDefaults.standard.set(formatDate(date: alarmList[indexPath.row]), forKey: "alarm")
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func formatDate(date : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
}






