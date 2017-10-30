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
    public let paymentDetails: PaymentDetails
  // Used in order to deturman if the object was already used to make a payment.
    internal var isPaid = false
    
    internal init?(paymentDetails: PaymentDetails , json: JSON) {
    self.paymentDetails = paymentDetails
    guard let tax: Double = "totalTax" <~~ json,
    let subtotal: Double = "totalBeforeTax" <~~ json ,
    let total: Double = "totalAfterTax" <~~ json else{
 
      return nil
    }
    self.taxValue = Money(value: tax)
    self.subtotalValue = Money(value: subtotal)
    self.totalValue = Money(value: total)

  }
}


extension PaymentRequest: PaymentDetailsProtocol{
    
    public var subtotalEntry: BillEntryItem{ get{ return BillEntryItem(name: "Subtotal"  , amount: subtotalValue)}}
    
    public var taxEntry:  BillEntryItem?{ get{ return BillEntryItem(name: "Tax"  , amount: taxValue)}}
    
    public var tipEntry:  BillEntryItem?{ get{ return BillEntryItem(name: "Tip"  , amount: paymentDetails.tip)}}
    
    public var totalEntry:  BillEntryItem{ get{ return BillEntryItem(name: "Total"  ,amount: totalValue)}}
}
