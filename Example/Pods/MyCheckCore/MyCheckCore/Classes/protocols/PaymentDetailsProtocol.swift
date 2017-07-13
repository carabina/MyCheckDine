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
    var subtotal: BillEntryItem{get }
    var tax: BillEntryItem?{get }
    
    var tip: BillEntryItem?{get }
    
    var total: BillEntryItem{get }
    
}

public extension PaymentDetailsProtocol{
    func getOrderedBillEntryArray() -> [BillEntryItem] {
        return [subtotal, tax , tip , total].flatMap {$0} //flat map removes the nil objects.
    }
}
