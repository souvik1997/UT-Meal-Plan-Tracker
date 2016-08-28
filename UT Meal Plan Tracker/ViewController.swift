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
    var controllers: [TransactionViewController?] = []
    
    var username: String?
    var password: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dineInController = storyboard?.instantiateViewController(withIdentifier: "TransactionViewController") as? TransactionViewController
        bevoBucksController = storyboard?.instantiateViewController(withIdentifier: "TransactionViewController") as? TransactionViewController
        dineInController!.name = "Dine-in Dollars"
        dineInController!.url = URL(string: "https://utdirect.utexas.edu/hfis/transDwnld.WBY")
        bevoBucksController!.name = "Bevo Bucks"
        bevoBucksController!.url = URL(string: "https://utdirect.utexas.edu/bevobucks/bevoDwnld.WBY")
        controllers = [dineInController, bevoBucksController]
        for i in 0..<controllers.count {
            self.addChildViewController(controllers[i]!)
            controllers[i]!.didMove(toParentViewController: self)
            self.scrollView.addSubview(controllers[i]!.view)
        }
        self.viewWillLayoutSubviews()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.delayedRefresh), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.logout), name: UserDefaults.didChangeNotification, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillLayoutSubviews() {
        let bounds = UIScreen.main.applicationFrame
        let width = bounds.width
        let height = bounds.height
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: 2 * width, height: height)
        for i in 0..<controllers.count {
            let originX = CGFloat(i) * width
            controllers[i]!.view.frame = CGRect(x: originX, y: CGFloat(0), width: width, height: height)
        }
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
    
    
    func delayedRefresh() {
        // hack to work around race condition
        let _ = setTimeout(delay: 2, block: {
            self.refresh()
        })
    }
    
    func logout() {
        // clear cookies
        let cookieStore = HTTPCookieStorage.shared
        for cookie in cookieStore.cookies ?? [] {
            cookieStore.deleteCookie(cookie)
        }
        UserDefaults.standard.synchronize()
        username = UserDefaults.standard.string(forKey: "uteid_eid")
        password = UserDefaults.standard.string(forKey: "uteid_password")
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
        self.logout()
        if (username == nil || username?.characters.count == 0 || password == nil || password?.characters.count == 0) {
            promptForCredentials()
            return
        }
        let defaults = UserDefaults.init(suiteName: "group.UT-Meal-Plan-Tracker")
        if (defaults != nil) {
            defaults?.set(username, forKey: "uteid_eid")
            defaults?.set(password, forKey: "uteid_password")
        }
        let loginHandler = LoginHandler(eid: username!, password: password!)
        loginHandler.authGet(url: URL(string: "https://utdirect.utexas.edu/utdirect/index.WBX")!, callback: {(result, data) in
            DispatchQueue.main.async(execute: {
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
                    let alert = UIAlertController(title: "Network Error", message: "UT's servers may be down; please try again later", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if (result == LoginResult.UTWebsiteError) {
                    let alert = UIAlertController(title: "UT Website Error", message: "Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        })
    }
    
    func setTimeout(delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    
    
    


}

