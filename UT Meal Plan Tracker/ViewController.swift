//
//  ViewController.swift
//  UT Meal Plan Tracker
//
//  Created by Souvik Banerjee on 8/15/16.
//  Copyright © 2016 Souvik Banerjee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.getData), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        getData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func promptForCredentials() {
        let alert = UIAlertController(title: "Enter Login Credentials In Settings", message: "Enter your EID and password in Settings", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default, handler: { (action) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getData() {
        UserDefaults.standard.synchronize()
        guard let username = UserDefaults.standard.string(forKey: "uteid_eid"), let password = UserDefaults.standard.string(forKey: "uteid_password") else {
            promptForCredentials()
            return
        }
        if (username.characters.count == 0 || password.characters.count == 0) {
            promptForCredentials()
            return
        }
        let loginHandler = LoginHandler(eid: username, password: password)
        loginHandler.authGet(url: URL(string: "https://utdirect.utexas.edu/bevobucks/bevoDwnld.WBY")!, callback: {(success, data) in
            if (success) {
                let t = TransactionParser(data: data)
                print(t.transactions)
            } else {
                print("Failed to login! \(username), \(password)")
            }
        })
        loginHandler.authGet(url: URL(string: "https://utdirect.utexas.edu/hfis/transDwnld.WBY")!, callback: {(success, data) in
            if (success) {
                let t = TransactionParser(data: data)
                print(t.transactions)
                print(t.name)
            }
        })
        /* for testing
         let t = TransactionParser(data: "Bevo Bucks Transaction Listing for SOUVIK BANERJEE\n" +
            "Date & Time\tLocation\tPlan\tCredit/Debit\tAmount\tRemaining Balance\n" +
            "8/10/2016  9:13 AM\tAdditions/Adjustments\tBevo Bucks\tCredit\t$   +300.00\t$   301.85\n" +
            "5/09/2016 12:25 PM\tCarother Laundry Dryer\tBevo Bucks\tDebit\t$ -      1.00\t$     1.85\n" +
            "5/09/2016 11:46 AM\tCarothers Laundry washe\tBevo Bucks\tDebit\t$ -      1.00\t$     2.85\n" +
            "5/09/2016 11:46 AM\tCarothers Laundry washe\tBevo Bucks\tDebit\t$ -      1.00\t$     3.85\n")
        print(t.transactions)*/
    }
    
    
    
    
    


}

