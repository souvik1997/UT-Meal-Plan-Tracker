//
//  TransactionViewController.swift
//  UT Meal Plan Tracker
//
//  Created by Souvik Banerjee on 8/18/16.
//  Copyright © 2016 Souvik Banerjee. All rights reserved.
//

import Foundation
import UIKit

class TransactionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chart: Chart!
    let refreshControl = UIRefreshControl()
    
    var transactions: TransactionParser?
    public var url: URL?
    public var name: String?
    let cellIdentifier = "TransactionViewControllerIdentifier"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        refreshView()
        refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(TransactionViewController.refreshControlPulled), for: UIControlEvents.valueChanged)
        self.tableView.delegate = self
        self.tableView.addSubview(self.refreshControl)
        self.tableView.dataSource = self
    }
    
    func refreshView() {
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        self.typeLabel.text = self.name ?? ""
        if (self.transactions != nil) {
            self.balanceLabel.text = self.transactions?.balance.toCurrencyString()
        } else {
            self.balanceLabel.text = ""
        }
        self.updateChart()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TransactionTableCell
        guard let transactions = self.transactions, row <= transactions.transactions.count else {
            return cell
        }
        cell.backgroundColor = UIColor.clear
        cell.reload(transaction: transactions.transactions[row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (transactions?.transactions.count) ?? 0
    }
    
    func refreshControlPulled() {
        UserDefaults.standard.synchronize()
        guard let username = UserDefaults.standard.string(forKey: "uteid_eid"), let password = UserDefaults.standard.string(forKey: "uteid_password") else {
            return
        }
        let loginHandler = LoginHandler(eid: username, password: password)
        self.refresh(loginHandler: loginHandler)
    }
    
    func updateChart() {
        guard let transactions = self.transactions, let finalDate = transactions.transactions.first?.date, let initialDate = transactions.transactions.last?.date else {
            chart.series = []
            chart.setNeedsDisplay()
            return
        }
        var data: Array<(x: Float, y: Float)> = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        for i in 0..<transactions.transactions.count {
            let transaction = transactions.transactions[i]
            guard let transactionDate = transaction.date, let transactionRemaining = transaction.remaining else {
                continue
            }
            let timeInterval = transactionDate.timeIntervalSince(initialDate) as Double
            let remaining = transactionRemaining as NSNumber
            data.append((x: Float(timeInterval), y: Float(remaining)))
        }
        let series = ChartSeries(data: data)
        series.area = true
        series.color = UIColor.white
        let halfwayDate = initialDate.addingTimeInterval(finalDate.timeIntervalSince(initialDate) / 2)
        chart.xLabels = [0, Float(finalDate.timeIntervalSince(initialDate) / 2)]
        chart.xLabelsFormatter = { (index, _) in
            if (index == 0) {
                return dateFormatter.string(from: initialDate)
            } else {
                return dateFormatter.string(from: halfwayDate)
            }
        }
        chart.series = [series]
        chart.setNeedsDisplay()
    }
    
    func refresh(loginHandler: LoginHandler?) {
        guard let url = self.url, let loginHandler = loginHandler else {
            return
        }
        loginHandler.authGet(url: url, callback: {(result, data) in
            if (result == LoginResult.Success) {
                DispatchQueue.main.async(execute: {
                    self.transactions = TransactionParser(data: data)
                    self.refreshView()
                })
            } else {
                print("Failed to login!")
            }
        })
        
    }
}
