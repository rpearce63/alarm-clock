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
    
    var alarms: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setTableBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let alarms = UserDefaults.standard.array(forKey: "alarmList") as? [String] {
            self.alarms = alarms.sorted()
        }
        tableView.reloadData()
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        UserDefaults.standard.set(alarms, forKey: "alarmList")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
    }
    
    func setTableBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.gray, UIColor.lightText]
        gradient.frame = tableView.bounds
        tableView.layer.addSublayer(gradient)
    }

}

extension AlarmListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell") else { return UITableViewCell() }
        cell.textLabel?.font = UIFont(name: "Avenir Next", size: 24)
        cell.textLabel?.text = alarms[indexPath.row]
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = #colorLiteral(red: 0.9188147187, green: 0.9188147187, blue: 0.9188147187, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            alarms.remove(at: indexPath.row)
        }
        tableView.reloadData()
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
                    UserDefaults.standard.set(alarms[indexPath.row], forKey: "alarm")
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
}






