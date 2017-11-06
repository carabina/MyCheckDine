//
//  File.swift
//  MyCheckDine
//
//  Created by elad schiller on 11/1/17.
//

import Foundation
import MyCheckCore

extension  URIs{
    
//    static let getBenefits = "/restaurants/api/v1/benefits"
//    static let redeemBenefits = "/restaurants/api/v1/redeemBenefits"
    
    
}

/// This object enables the ability to query the list of benefits that can be displyed to the user and redeem them if the benefit's type allowes it.
public class Benefits{
    fileprivate static let redemptionSuccessCode = 12001
    
    
    internal static var network : RequestProtocol = Networking.shared
    
    
    /// Returns the list of benefits that can be displayed to the user.
    ///
    /// - Parameters:
    ///   - restaurantId: The restuarant Id. This is optional. If set, in some cases, restaurant specific benefits will be added to list of benefits.
    ///   - success: This callback will be called when a list of benefits is successfully retrieved
    ///   - fail: Called when the request fails.
    public static func getBenefits(restaurantId: String?,
                                   success: @escaping (([Benefit]) -> Void),
                                   fail:  ((NSError) -> Void)?){
        var params : [String: Any] = [:]
        
        if let restaurantId = restaurantId{
            params["businessId"] = restaurantId
        }
        
        
        guard let domain = Networking.shared.domain else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
            return
        }
        let urlStr = domain + "/restaurants/api/v1/benefits"
        
        return  network.request(urlStr, method: .get, parameters: params , success: { JSON in
            
            
            guard let benefitsJSONArray = JSON["benefits"] as? [[String:Any]] else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
                return
            }
            
            let benefitsArray = benefitsJSONArray.map({Benefit(JSON: $0)}).flatMap{$0}
            
            guard benefitsArray.count == benefitsJSONArray.count else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
                return
            }
            
            success(benefitsArray)
        }, fail: fail)
    }
    
    /// Redeems a single benefit.
    ///
    /// - Parameters:
    ///   - benefit: The benefit that should be redeemed.
    ///   - restaurantId: The Id of the restaurant related to the redeem (optional)
    ///   - success: This callback will be called when a benefit is successfully redeemed.
    ///   - fail: Called when the request fails.
    public static func redeem(benefit: BasicBenefit,restaurantId: String?, success: @escaping (() -> Void),
                              fail:  ((NSError) -> Void)?){
        
        let benefitJSON : [String: Any] = ["id": benefit.id, "provider": benefit.provider]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: [benefitJSON], options: JSONSerialization.WritingOptions())
        
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        var params : [String: Any] = ["benefits":jsonString]
        
        if let restaurantId = restaurantId{
            params["businessId"] = restaurantId
        }
        
        
        guard let domain = Networking.shared.domain else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
            return
        }
        let urlStr = domain + "/restaurants/api/v1/redeemBenefits"
        
        return  network.request(urlStr, method: .post, parameters: params , success: { JSON in
            
            
            guard let redemptionsJSONArray = JSON["redemptions"] as? [[String:Any]] else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
                return
            }
            
            
            
            guard redemptionsJSONArray.count == 1 else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
                return
            }
            let redemtionJSON = redemptionsJSONArray[0]
            
            guard let outcome = redemtionJSON["outcome"] as? Int else{
                if let fail = fail{
                    fail(ErrorCodes.badJSON.getError())
                }
                return
                
            }
            if outcome == redemptionSuccessCode{
                success()
                
            }else{
                guard let fail = fail else {
                    return
                }
                guard let errorMsg = redemtionJSON["error"] else{
                    fail(ErrorCodes.badJSON.getError())
                    return
                }
                let error = NSError(domain: "MyCHeck local error domain", code: outcome, userInfo:  [NSLocalizedDescriptionKey : errorMsg])
                fail(error)
                
                
            }
        }, fail: fail)
    }
    
}

fileprivate extension Benefits{
    
    
}





