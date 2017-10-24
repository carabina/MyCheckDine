//
//  PrePaySummary.swift
//  MyCheckDine
//
//  Created by elad schiller on 24/10/2017.
//

import Foundation
import MyCheckCore
import Gloss
public struct PrePaySummary{
  
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
  
  private let taxValue: Money
  private let subtotalValue: Money
  private let totalValue: Money
  
  
  internal init?(json: JSON) {
    
    guard let tax: Double = "totalTax" <~~ json,
    let subtotal: Double = "subtotal" <~~ json ,
    let total: Double = "total" <~~ json else{
      return nil
    }
    self.taxValue = Money(value: tax)
    self.subtotalValue = Money(value: subtotal)
    self.totalValue = Money(value: total)

  }
}
