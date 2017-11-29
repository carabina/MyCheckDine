//
//  OrderJSONGenerator.swift
//  Pods
//
//  Created by elad schiller on 8/23/17.
//
//

import Foundation

import MyCheckDine

internal struct OrderJSONGenerator{
    static func createJSONRepresentaion(order:Order ) -> [String: Any]{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let items = order.items.map{createJSONRepresentaion(item: $0) }
      
        let summary = createGlobalSummeryJSONRepresentaion(order: order)
        
        let userSummary : [String: Any] = ["paid_amount": order.summary.userSummary.paidAmount,
                                           "paid_tip": order.summary.userSummary.paidTip
        ]
        
        let bill :[String:Any] = ["global_summary": summary,
                                  "user_summary": userSummary]
        
        let settings :[String:Any] = ["is_quick_service": order.settings.quickService,
                                  "split_is_enabled": order.settings.splitEnabled]
        
        let taxSettings: [String: Any] = ["percentage": order.tax.percentage]
        
        let JSON: [String: Any] = ["stamp": order.stamp,
                                   "order_id": order.orderId,
                                   "order_status": order.status.rawValue,
                                   "restaurant_id": order.restaurantId,
                                   "open_time": dateFormatter.string(from: order.openTime),
                                   "client_code": order.clientCode,
                                   "items": items,
                                   "bill": bill,
                                   "settings":settings,
                                   "tax_settings":taxSettings
        ]
        return JSON
    }
    
    
    
}

fileprivate extension OrderJSONGenerator{
    static func createJSONRepresentaion(item:Item ) -> [String: Any]{
        
        let modifiers = item.modifiers.map({createJSONRepresentaion(item: $0) })
        var JSON: [String: Any] = ["id": item.Id,
                                   "name": item.name,
                                   "price": item.price.roundedStringForJSON(),
                                   "quantity": item.quantity,
                                   "paid": item.paid,
                                   "valid_for_reorder": item.validForReorder,
                                   "show_in_reorder": item.showInReorder,
                                   "modifiers": modifiers]
        if let serialId = item.serialId{
            JSON["serial_id"] = serialId
            
        }
        return JSON
    }
    
    static func createGlobalSummeryJSONRepresentaion(order: Order ) -> [String: Any]{
        
        
        let JSON: [String: Any] = ["paid_amount": order.summary.paidAmount.roundedStringForJSON(),
                                   "total_amount": order.summary.totalAmount.roundedStringForJSON(),
                                   "balance": order.summary.balance.roundedStringForJSON(),
                                   "tax_amount": String(order.summary.taxAmount),
                                   "balance_without_tax": order.summary.balanceWithoutTax.roundedStringForJSON()
                                   ]
        
        return JSON
    }
    
}
