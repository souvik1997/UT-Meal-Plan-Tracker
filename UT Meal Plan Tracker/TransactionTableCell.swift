//
//  TransactionTableCell.swift
//  UT Meal Plan Tracker
//
//  Created by Souvik Banerjee on 8/18/16.
//  Copyright © 2016 Souvik Banerjee. All rights reserved.
//

import Foundation
import UIKit

class TransactionTableCell: UITableViewCell {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    
    
    func reload(transaction: Transaction) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        if (transaction.remaining != nil) {
            let formattedAmount = formatter.string(from: transaction.amount! as NSNumber)
            balanceLabel.text = "\(formattedAmount!)"
        }
        else {
            balanceLabel.text = "Error"
        }
        if (transaction.location != nil) {
            locationLabel.text = "\(transaction.location!)"
        }
        else {
            locationLabel.text = "Error"
        }
    }
    
    override func prepareForReuse() {
        balanceLabel.text = ""
        locationLabel.text = ""
    }
}


