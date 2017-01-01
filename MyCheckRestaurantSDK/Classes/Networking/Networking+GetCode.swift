//
//  Networking+GetCode.swift
//  Pods
//
//  Created by elad schiller on 12/25/16.
//
//

import UIKit
import Alamofire
extension Networking{

    
    /// The code generated by the MyCheck server is valid for a limited time, for a specific user in a specific location. The server returns a 4 digit code to the recipient. This code, when entered into the POS enables MyCheck to sync the client with his order on the POS and can start receiving order updates and perform actions on it.
  ///
  ///    - parameters:
  ///    - hotelId: The Id of the hotel the venue belongs to. [Optional]
  ///    - restaurantId: The restuarants Id.
  ///    - success: A block that is called if the call complete succesfully
  ///    - fail: Called when the function fails for any reason
 

    func generateCode( hotelId: String?, restaurantId: String, success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ) -> Alamofire.Request?{
      
        var params : Parameters = [  "restaurant_id" :  restaurantId]
        
        if let hotelId = hotelId{
        params ["hotelId"] = hotelId
        }
        if let domain = domain {
            let urlStr = domain + "/restaurants/api/v1/generateCode"
            
            return  request(urlStr, method: .post, parameters: params , success: { JSON in
                if let code = JSON["code"] as? NSNumber{
                    success(code.stringValue)
   
                }else{
                    if let fail = fail{
                        fail(self.badJSONError())
                    }
                }
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(self.notConfiguredError())
            }
        }
        return nil
    }

}
