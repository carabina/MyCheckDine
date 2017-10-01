//
//  OrderHistoryItem.swift
//  Pods
//
//  Created by elad schiller on 8/20/17.
//
//

import Foundation
import Gloss


/// A past order summery
public struct OrderHistoryItem{
    
    /// The order Id
    let orderId: String
    /// The date the order was opened
    let date: Date
    /// The name of the bussiness the order was opened at
    let businessName: String
    /// The currancy of the bussiness the order was opened at
    let businessCurrency: String
    /// The total amount paid
    let paymentAmount: Float
    
    
    internal  init?(json: JSON){
        guard let orderId: Int = "orderId" <~~ json else{
            return nil
        }
        self.orderId = String(orderId)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let dateStr: String = "date" <~~ json,
        let tmpDate = dateFormatter.date(from: dateStr) else{
            return nil
        }
        self.date = tmpDate 
        
        guard let businessName: String = "businessName" <~~ json else{
            return nil
        }
        self.businessName = businessName
        
        guard let businessCurrency: String = "businessCurrency" <~~ json else{
            return nil
        }
        self.businessCurrency = businessCurrency
        
        guard let paymentAmount: Float = "paymentAmount" <~~ json else{
            return nil
        }
        self.paymentAmount = paymentAmount
        
    }
}
