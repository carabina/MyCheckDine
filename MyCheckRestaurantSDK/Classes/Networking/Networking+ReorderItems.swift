//
//  Networking+ReorderItems.swift
//  Pods
//
//  Created by elad schiller on 28/12/2016.
//
//

import UIKit
import Alamofire
import Gloss
extension Networking{
  
  //Place an order to the POS. The items sent will be reordered and served to the user. This will only succeed if their is an open order.
  open func reorderItems(items: [(amount: Int , item: Item)] , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ) -> Alamofire.Request?{
    
    //creating items JSON
    var itemJSONs :[JSON] = []
    for (amount , item) in items{
      guard let json = item.createReorderJSON(amount: amount)else{
      continue
      }
      
      itemJSONs.append(json)
    }
    let jsonData = try! JSONSerialization.data(withJSONObject: itemJSONs, options: JSONSerialization.WritingOptions())

    let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as! String
    var params : Parameters = ["items": jsonString]
    
  
    if let domain = domain {
      let urlStr = domain + "/restaurants/api/v1/reorder"
      
      return  request(urlStr, method: .post, parameters: params , success: { JSON in
        
        success()
          
        
      }, fail: fail)
    }else{
      if let fail = fail{
        fail(self.notConfiguredError())
      }
    }
    return nil
  }

  
 
  }


