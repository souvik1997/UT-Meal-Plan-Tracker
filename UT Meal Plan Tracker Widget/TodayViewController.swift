//
//  TodayViewController.swift
//  UT Meal Plan Tracker Widget
//
//  Created by Souvik Banerjee on 8/16/16.
//  Copyright © 2016 Souvik Banerjee. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var dineInDollarsLabel: UILabel!
    @IBOutlet weak var bevoBucksLabel: UILabel!
    @IBOutlet weak var dineInDollarsBalanceLabel: UILabel!
    @IBOutlet weak var bevoBucksBalanceLabel: UILabel!
    @IBOutlet weak var credentialPromptLabel: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        bevoBucksBalanceLabel.text = "--"
        dineInDollarsBalanceLabel.text = "--"
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        widgetPerformUpdate(completionHandler: {(junk) in })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func promptForCredentials(msg: String) {
        credentialPromptLabel.isHidden = false
        credentialPromptLabel.text = msg
        dineInDollarsLabel.isHidden = true
        bevoBucksLabel.isHidden = true
        dineInDollarsBalanceLabel.isHidden = true
        bevoBucksBalanceLabel.isHidden = true
    }
    
    func hidePrompt() {
        credentialPromptLabel.isHidden = true
        dineInDollarsLabel.isHidden = false
        bevoBucksLabel.isHidden = false
        dineInDollarsBalanceLabel.isHidden = false
        bevoBucksBalanceLabel.isHidden = false
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        let defaults = UserDefaults.init(suiteName: "group.UT-Meal-Plan-Tracker")
        guard let username = defaults?.string(forKey: "uteid_eid"), let password = defaults?.string(forKey: "uteid_password") else {
            self.promptForCredentials(msg: "Enter Credentials In Settings (1)")
            return
        }
        if (username.characters.count == 0 || password.characters.count == 0) {
            self.promptForCredentials(msg: "Enter Credentials In Settings")
            return
        }
        let loginHandler = LoginHandler(eid: username, password: password)
        loginHandler.authGet(url: URL(string: "https://utdirect.utexas.edu/bevobucks/bevoDwnld.WBY")!, callback: {(success, data) in
            if (success) {
                let t = TransactionParser(data: data)
                DispatchQueue.main.async(execute: {
                    self.bevoBucksBalanceLabel.text = t.balance.toCurrencyString()
                })
                loginHandler.authGet(url: URL(string: "https://utdirect.utexas.edu/hfis/transDwnld.WBY")!, callback: {(success, data) in
                    if (success) {
                        let t = TransactionParser(data: data)
                        DispatchQueue.main.async(execute: {
                            self.dineInDollarsBalanceLabel.text = t.balance.toCurrencyString()
                            self.hidePrompt()
                            completionHandler(NCUpdateResult.newData)
                        })
                    } else {
                        DispatchQueue.main.async(execute: {
                            completionHandler(NCUpdateResult.failed)
                        })
                    }
                })
            } else {
                print("Failed to login! \(username), \(password)")
                DispatchQueue.main.async(execute: {
                    completionHandler(NCUpdateResult.failed)
                })
            }
            
        })
        
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        
    }
    
}
