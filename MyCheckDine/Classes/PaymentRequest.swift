//
//  PaymentRequest.swift
//  Pods
//
//  Created by elad schiller on 4/30/17.
//
//

import UIKit

/// A request represents a payment on a specific order.
open class PaymentRequest {
   private var order : Order
    
    
    
    /// Create a new payment request for the underlying order supplied.
    ///
    ///   - parameter order: The order that is going to be paid for. If only an order is supplied the payment amount will be the full balance of the order.
    ///   - parameter amount: The amount that is going to be paid. The value must be between 0 and the order balance.

   public init(order: Order , amount:Double? = nil ) {
        self.order = order
    }
    
    
    /// Create a new payment request for the underlying order supplied.
    ///
    ///   - parameter order: The order that is going to be paid for. If only an order is supplied the payment amount will be the full balance of the order.
    ///   - parameter items: The items that should be paid for. The total amount that will be sent will be the sum of all the items prices with tax
   public init(order: Order , items:[Item] ) {
        self.order = order
    }
    
}
