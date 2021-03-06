//
//  Networking+Order.swift
//  Pods
//
//  Created by elad schiller on 12/25/16.
//
//

import UIKit
import MyCheckCore
import Alamofire

extension Dine{
  
  
  /// Returns the updated order details. if nothing changed an error will be returned. If no order Id is supplied the last order will be returned if it is open.
  ///
  ///    - parameters:
  ///    - orderId: The Id of the order. If no order Id is supplied the last order will be returned if it is open. [Optional]
  ///    - stamp: The stamp of the last order you received. This will allow the server to only return an order if an update accured.
  ///    - success: A block that is called if the call complete succesfully
  ///    - fail: Called when the function fails for any reason
  
  func callGetOrder( orderId: String?, stamp: String?, success: @escaping ((Order) -> Void) , fail: ((NSError) -> Void)? ) {
        var params : [String: Any] = ["requestID":randomString(length: 8)]
    
    if let orderId = orderId{
      params ["orderId"] = orderId
    }

    if let stamp = stamp{
      params ["stamp"] = stamp
    }
    if let domain = Networking.shared.domain {
      let urlStr = domain + URIs.orderDetails 
      
        network.request(urlStr, method: .get, parameters: params, success: { JSON in
        guard let order = Order(json: JSON) else {
          guard let fail = fail else{
            return
          }
          fail(ErrorCodes.badJSON.getError())

        return
        }
            
            
        success(order)
            self.pollerManager.order = order // updating the poller with the latest order details

      }, fail: fail)
    }else{
      if let fail = fail{
        fail(ErrorCodes.notConifgured.getError())
      }
    }
  }
  
}

fileprivate extension Dine{
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
