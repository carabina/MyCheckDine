//
//  PaymentRequest.swift
//  MyCheckDine
//
//  Created by elad schiller on 24/10/2017.
//

import Foundation
import MyCheckCore
import Gloss
public struct PaymentRequest{
  
  public var taxAmount: Double{
    get{
    return taxValue.rawValue
    
    }
    
  }
  
  public var subtotal: Double{
    get{
    return subtotalValue.rawValue
    
    }
    
  }
  
  public var total: Double{
    get{
    return totalValue.rawValue
    
    }
    
  }
  
  fileprivate let taxValue: Money
  fileprivate let subtotalValue: Money
  fileprivate let totalValue: Money
    
    /// The payment details for the upcoming payment.
    public var paymentDetails: PaymentDetails
  
  // Used in order to deturman if the object was already used to make a payment.
    internal var isPaid = false

  /// The list of tax items. Each tax item reprisents a diffrant type of tax that will be charged when the request is processed.
  public let taxItems: [TaxItem]

    internal init?(paymentDetails: PaymentDetails , json: JSON) {
    self.paymentDetails = paymentDetails
    guard let tax: Double = "totalTax" <~~ json,
    let subtotal: Double = "priceBeforeTax" <~~ json ,
    let total: Double = "priceAfterTax" <~~ json else{
 
      return nil
    }
    self.taxValue = Money(value: tax)
    self.subtotalValue = Money(value: subtotal)
    self.totalValue = Money(value: total)

      guard let JSONArray = json["taxList"] as? [[String: Any]]
         else{
          return nil
      }
       taxItems = JSONArray.map({ TaxItem(JSON:$0) }).flatMap({$0})
      
  }
}


extension PaymentRequest: PaymentDetailsProtocol{
    
    public var subtotalEntry: BillEntryItem{ get{ return BillEntryItem(name: "Subtotal"  , amount: subtotalValue)}}
    
    public var taxEntry:  BillEntryItem?{ get{ return BillEntryItem(name: "Tax"  , amount: taxValue)}}
    
    public var tipEntry:  BillEntryItem?{ get{ return BillEntryItem(name: "Tip"  , amount: paymentDetails.tipValue)}}
    
    public var totalEntry:  BillEntryItem{ get{ return BillEntryItem(name: "Total"  ,amount: totalValue)}}
}
