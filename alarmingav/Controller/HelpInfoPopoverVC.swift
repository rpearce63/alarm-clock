//
//  HelpInfoPopoverVC.swift
//  alarm-clock
//
//  Created by Rick on 6/14/19.
//  Copyright © 2019 Rick Pearce. All rights reserved.
//

import UIKit

class HelpInfoPopoverVC : UIViewController, UIPopoverPresentationControllerDelegate {
    
    var content : String = ""
    
    @IBOutlet weak var helpText: UILabel!
    
    override func viewDidLoad() {
        helpText.text = content
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverSegue" {
            let popoverVC = segue.destination as UIViewController
            popoverVC.modalPresentationStyle = .popover
            popoverVC.popoverPresentationController?.delegate = self
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
