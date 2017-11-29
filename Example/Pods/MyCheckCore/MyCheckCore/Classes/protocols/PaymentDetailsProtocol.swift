//
//  File.swift
//  Pods
//
//  Created by elad schiller on 6/27/17.
//
//

import Foundation

///reprisents
public protocol PaymentDetailsProtocol {
    var subtotalEntry: BillEntryItem{get }
    
    var taxEntry: BillEntryItem?{get }
    
    var tipEntry: BillEntryItem?{get }
    
    var totalEntry: BillEntryItem{get }
    
}

public extension PaymentDetailsProtocol{
    func getOrderedBillEntryArray() -> [BillEntryItem] {
        return [subtotalEntry, taxEntry , tipEntry , totalEntry].flatMap {$0} //flat map removes the nil objects.
    }
}
