//
//  Networking+Order.swift
//  Pods
//
//  Created by elad schiller on 12/25/16.
//
//

import UIKit
import Alamofire
extension Networking{
  
  
  /// Returns the updated order details. if nothing changed an error will be returned. If no order Id is supplied the last order will be returned if it is open.
  ///
  ///    - parameters:
  ///    - orderId: The Id of the order. If no order Id is supplied the last order will be returned if it is open. [Optional]
  ///    - md5: The md5 of the last order you received. This will allow the server to only return an order if an update accured.
  ///    - success: A block that is called if the call complete succesfully
  ///    - fail: Called when the function fails for any reason
  

  func getOrder( orderId: String?, md5: String?, success: @escaping ((Order) -> Void) , fail: ((NSError) -> Void)? ) -> Alamofire.Request?{
    var params : Parameters = [   :  ]
    
    if let orderId = orderId{
      params ["orderId"] = orderId
    }
    if let md5 = md5{
      params ["md5"] = md5
    }
    if let domain = domain {
      let urlStr = domain + "/restaurants/api/v1/order"
      
      return  request(urlStr, method: .get, parameters: params , success: { JSON in
        guard let order = Order(json: JSON) else {
          guard let fail = fail else{
            return
          }
          fail(self.badJSONError())

        return
        }
        success(order)
      }, fail: fail)
    }else{
      if let fail = fail{
        fail(self.notConfiguredError())
      }
    }
    return nil
  }
  
}
