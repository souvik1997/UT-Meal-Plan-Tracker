//
//  TransactionsParser.swift
//  UT Meal Plan Tracker
//
//  Created by Souvik Banerjee on 8/18/16.
//  Copyright © 2016 Souvik Banerjee. All rights reserved.
//

import Foundation

struct Transaction {
    let date: Date?
    let location: String?
    let amount: Decimal?
    let remaining: Decimal?
}

class TransactionParser {
    var transactions: [Transaction]
    var balance: Decimal
    var name: String?
    
    init(data: String) {
        let lines = data.components(separatedBy: CharacterSet.newlines).filter { $0.characters.count != 0 }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/dd/yyyy h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone(abbreviation: "CDT")
        let numberFormatter = NumberFormatter()
        numberFormatter.generatesDecimalNumbers = true
        
        self.transactions = []
        for i in 0 ..< min(lines.count, 21) {
            let line = lines[i]
            let splitStr = line.characters.split(separator: "\t")
            if (i == 0) { // header
                let headerStr = String(line)
                if (headerStr?.contains("Bevo Bucks"))! {
                    self.name = headerStr?.substring(from: (headerStr?.index((headerStr?.startIndex)!, offsetBy: 35))!)
                } else if (headerStr?.contains("Dine In"))! {
                    self.name = headerStr?.substring(from: (headerStr?.index((headerStr?.startIndex)!, offsetBy: 40))!)
                }
            } else if (i > 1 && splitStr.count == 6) {
                let date = dateFormatter.date(from: String(splitStr[0]))
                let location = String(splitStr[1])
                let cleanAmountStr = String(splitStr[4].dropFirst()).removeSpaces()
                let cleanRemainingStr = String(splitStr[5].dropFirst()).removeSpaces()
                numberFormatter.positivePrefix = "+"
                let amount = numberFormatter.number(from: cleanAmountStr) as? Decimal
                numberFormatter.positivePrefix = ""
                let remaining = numberFormatter.number(from: cleanRemainingStr) as? Decimal
                let transaction = Transaction(date: date, location: location, amount: amount, remaining: remaining)
                self.transactions.append(transaction)
            }
        }
        self.balance = self.transactions[0].remaining ?? 0
    }
    
    private func trim(string: String) -> String {
        return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
