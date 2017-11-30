//
//  BillEntryItem.swift
//  Pods
//
//  Created by elad schiller on 6/28/17.
//
//

import Foundation


public struct BillEntryItem{
   public let name: String
   public let amount: Money
    
   public init(name: String ,amount: Money) {
        self.name = name
        self.amount = amount
    }
    
   public init(name: String, sumOfItems: [BillEntryItem]){
        self.name = name
        amount = sumOfItems.reduce(Money(value:0) ,{ $0 + $1.amount })
        
        
    }
}
