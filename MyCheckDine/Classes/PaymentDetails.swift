//
//  PaymentRequest.swift
//  Pods
//
//  Created by elad schiller on 4/30/17.
//
//

import UIKit
import MyCheckCore
/// A request represents a payment on a specific order.
public struct PaymentDetails {
    internal let order : Order
    internal let amount: Money
    internal let tip: Money
    internal let paymentMethod: PaymentMethodInterface
    internal let items: [Item]?
    
    
    /// Create a new payment request for the underlying order supplied. If the amount is bigger than the order balance or if the order is not open nil will be returned.
    ///
    ///   - parameter order: The order that is going to be paid for. If only an order is supplied the payment amount will be the full balance of the order.
    ///   - parameter amount: The amount that is going to be paid. The value must be between 0 and the order balance.
    ///   - parameter tip: The tip that is going to be paid. If not supplied 0 tip will be paid.
    ///   - parameter paymentMethodToken: The payment method token that should be used for chaging.
    
    public init?(order: Order , amount:Double? = nil , tip:Double? = nil ,paymentMethod: PaymentMethodInterface) {
        self.order = order
        self.paymentMethod = paymentMethod
        if let amount = amount {
            self.amount = Money(value: amount)
        }else{
            self.amount = Money(value:order.summary.balance)
        }
        
        if let tip = tip {
            self.tip = Money(value: tip)
        }else{
            self.tip = Money(value:0)
        }
        
        //If the amount is not within the bounds we will return nil
        if self.amount > Money(value: order.summary.balance) || order.status != .open{
            return nil
        }
        items = nil
    }
    
    
    /// Create a new payment request for the underlying order supplied. The amount will be calculated as the sum of all the unpaid items. If the order is not open or if the sum is larger than the balance nil will be returned.
    ///
    ///   - parameter order: The order that is going to be paid for. If only an order is supplied the payment amount will be the full balance of the order.
    ///   - parameter items: The items that should be paid for. The total amount that will be sent will be the sum of all the items prices with tax
    ///   - parameter tip: The tip that is going to be paid. If not supplied 0 tip will be paid.
    ///   - parameter paymentMethodToken: The payment method token that should be used for chaging.
    
    
    public init?(order: Order , items:[Item] , tip:Double? = nil ,paymentMethod: PaymentMethodInterface ) {
        self.order = order
        self.paymentMethod = paymentMethod
        
        //adding up all the items amount * quntity apart from the items that where already paid for
        self.amount = Money(value: items.reduce(0.0, {$1.paid ? $0 : $0 + $1.price * Double($1.quantity)}))
        self.items = items
        if let tip = tip {
            self.tip = Money(value: tip)
        }else{
            self.tip = Money(value:0)
        }
        
        //If the amount is not within the bounds we will return nil
        if self.amount > Money(value: order.summary.balance) || order.status != .open{
            return nil
        }
    }
    
}

extension PaymentDetails: PaymentDetailsProtocol{
    
    public var subtotalEntry: BillEntryItem{ get{ return BillEntryItem(name: "Subtotal"  , amount: self.amount)}}
    
    
    public var taxEntry:  BillEntryItem?{ get{ return nil}}
    
    public var tipEntry:  BillEntryItem?{ get{ return BillEntryItem(name: "Tip"  , amount: self.tip)}}
    
    public var totalEntry:  BillEntryItem{ get{ return BillEntryItem(name: "Total"  ,sumOfItems: [subtotalEntry , taxEntry , tipEntry].flatMap({$0}))}}
}
