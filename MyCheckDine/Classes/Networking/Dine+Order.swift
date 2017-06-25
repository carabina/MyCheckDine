//
//  Networking+Order.swift
//  Pods
//
//  Created by elad schiller on 12/25/16.
//
//

import UIKit
import MyCheckCore

extension Dine{
  
  
  /// Returns the updated order details. if nothing changed an error will be returned. If no order Id is supplied the last order will be returned if it is open.
  ///
  ///    - parameters:
  ///    - orderId: The Id of the order. If no order Id is supplied the last order will be returned if it is open. [Optional]
  ///    - stamp: The stamp of the last order you received. This will allow the server to only return an order if an update accured.
  ///    - success: A block that is called if the call complete succesfully
  ///    - fail: Called when the function fails for any reason
  
  func callGetOrder( orderId: String?, stamp: String?, success: @escaping ((Order) -> Void) , fail: ((NSError) -> Void)? ) {
        var params : [String: Any] = [   :  ]
    
    if let orderId = orderId{
      params ["orderId"] = orderId
    }
    if let stamp = stamp{
      params ["stamp"] = stamp
    }
    if let domain = network.domain {
      let urlStr = domain + "/restaurants/api/v1/order"
      
        network.request(urlStr, method: .get, parameters: params , success: { JSON in
        guard let order = Order(json: JSON) else {
          guard let fail = fail else{
            return
          }
          fail(ErrorCodes.badJSON.getError())

        return
        }
        success(order)
      }, fail: fail)
    }else{
      if let fail = fail{
        fail(ErrorCodes.notConifgured.getError())
      }
    }
  }
  
}
