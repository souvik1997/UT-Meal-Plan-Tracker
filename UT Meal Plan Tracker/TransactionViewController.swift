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
    
    var transactions: TransactionParser?
    public var url: URL?
    public var name: String?
    let cellIdentifier = "TransactionViewControllerIdentifier"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.typeLabel.text = self.name ?? ""
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TransactionTableCell
        guard let transactions = self.transactions, row <= transactions.transactions.count else {
            return cell
        }
        cell.reload(transaction: transactions.transactions[row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (transactions?.transactions.count) ?? 0
    }
    
    func refresh(loginHandler: LoginHandler?) {
        guard let url = self.url, let loginHandler = loginHandler else {
            return
        }
        loginHandler.authGet(url: url, callback: {(success, data) in
            if (success) {
                DispatchQueue.main.async(execute: {
                    self.transactions = TransactionParser(data: data)
                    self.tableView.reloadData()
                })
            } else {
                print("Failed to login!")
            }
        })
        
    }
}
