//
//  ViewController.swift
//  UT Meal Plan Tracker
//
//  Created by Souvik Banerjee on 8/15/16.
//  Copyright © 2016 Souvik Banerjee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var dineInController: TransactionViewController?
    var bevoBucksController: TransactionViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: 2 * width, height: height)
        
        dineInController = storyboard?.instantiateViewController(withIdentifier: "TransactionViewController") as? TransactionViewController
        bevoBucksController = storyboard?.instantiateViewController(withIdentifier: "TransactionViewController") as? TransactionViewController
        
        let controllers = [dineInController, bevoBucksController]
        for i in 0..<controllers.count {
            let originX = CGFloat(i) * width
            self.addChildViewController(controllers[i]!)
            controllers[i]!.view.frame = CGRect(x: originX, y: CGFloat(0), width: width, height: height)
            self.scrollView.addSubview(controllers[i]!.view)
            controllers[i]!.didMove(toParentViewController: self)
        }
    
        dineInController!.name = "Dine-in Dollars"
        dineInController!.url = URL(string: "https://utdirect.utexas.edu/hfis/transDwnld.WBY")
        
        bevoBucksController!.name = "Bevo Bucks"
        bevoBucksController!.url = URL(string: "https://utdirect.utexas.edu/bevobucks/bevoDwnld.WBY")
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.refresh), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.logout), name: UserDefaults.didChangeNotification, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = round(fractionalPage)
        self.pageControl.currentPage = Int(page)
    }
    override func viewDidAppear(_ animated: Bool) {
        refresh()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logout() {
        // clear cookies
        let cookieStore = HTTPCookieStorage.shared
        for cookie in cookieStore.cookies ?? [] {
            cookieStore.deleteCookie(cookie)
        }
    }
    
    func promptForCredentials() {
        let alert = UIAlertController(title: "Enter Login Credentials In Settings", message: "Enter your EID and password in Settings", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default, handler: { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
            } else {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func refresh() {
        UserDefaults.standard.synchronize()
        let defaults = UserDefaults.init(suiteName: "group.UT-Meal-Plan-Tracker")
        defaults?.synchronize()
        guard let username = UserDefaults.standard.string(forKey: "uteid_eid"), let password = UserDefaults.standard.string(forKey: "uteid_password") else {
            promptForCredentials()
            return
        }
        defaults?.set(username, forKey: "uteid_eid")
        defaults?.set(password, forKey: "uteid_password")
        if (username.characters.count == 0 || password.characters.count == 0) {
            promptForCredentials()
            return
        }
        let loginHandler = LoginHandler(eid: username, password: password)
        loginHandler.authGet(url: URL(string: "https://utdirect.utexas.edu/utdirect/index.WBX")!, callback: {(result, data) in
            if (result == LoginResult.Success) {
                self.bevoBucksController!.refresh(loginHandler: loginHandler)
                self.dineInController!.refresh(loginHandler: loginHandler)
            } else if (result == LoginResult.IncorrectCredentials) {
                let alert = UIAlertController(title: "Incorrect Login Credentials", message: "Enter your EID and password in Settings", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default, handler: { (action) in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                    } else {
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            } else if (result == LoginResult.NetworkError) {
                let alert = UIAlertController(title: "Network Error", message: "You need to be connected to the network", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            } else if (result == LoginResult.UTWebsiteError) {
                let alert = UIAlertController(title: "UT Website Error", message: "Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
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

