//
//  TaxItem.swift
//  MyCheckDine
//
//  Created by elad schiller on 31/10/2017.
//

import Foundation


/// Information about a specific type of tax that will be charged as part of an order.
public struct TaxItem: Equatable{

  
 /// The tax name
 public let name: String
 /// The amount od currancy that will be charged
 public let amount: Double
 /// Whether or not the tax is included in the items price
 public let isInclusive: Bool

  init?(JSON: [String:Any]){
    
    guard let name = JSON["name"] as? String,
    let amount = JSON["amount"] as? Double,
      let isInclusive = JSON["isInclusive"] as? Bool else{
        return nil
    }
    self.name = name
    self.amount = amount
    self.isInclusive = isInclusive
  }
  
  public static func ==(lhs: TaxItem, rhs: TaxItem) -> Bool {
    return lhs.name == rhs.name && lhs.amount == rhs.amount && lhs.isInclusive == rhs.isInclusive
  }
  
}
