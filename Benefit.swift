//
//  Benefit.swift
//  MyCheckDine
//
//  Created by elad schiller on 11/1/17.
//

import Foundation



/// Reprisents a benefit
public struct Benefit{
    
    
    /// The method the benefit can be redeemed by.
    ///
    /// - manual: In order to redeem redeem benefit must be called with this benefit
    /// - automatic: The benefit will be redeemed automaticly when the condition will be met
    public enum RedeemMethod: String{
        
        case manual = "MANUAL"
        
        case automatic = "AUTO"
        
    }
    
    
    /// The benefits id
    public let id: String
    
    /// The providers name
    public let provider: String
    
    /// The benefits name
    public let name: String
    
    /// Subtitle text for the benefit
    public let subtitle: String
    
    /// A description of the benefit
    public let description: String
    
    /// Whether or not the benefit redeemable
    public let  redeemable: Bool
    
    /// A url of an image for the benefit
    public let imageURL: URL?
    
    /// The Id of the category the benefit belongs to
    public let categoryID: String? 
    
    /// The method the benefit can be redeemed by (by calling the redeem function or automaticly)
    public let redeemMethod: RedeemMethod
    
    /// The date the benefit begins to be valid
    public let startDate: Date?
    
    /// The date the benefit expires
    public let expirationDate: Date?
    
    internal init?(JSON: [String: Any]){
        guard let id = JSON["id"] as? String,
            let provider = JSON["provider"] as? String,
            let name = JSON["name"] as? String,
            let subtitle = JSON["subtitle"] as? String,
            let description = JSON["description"] as? String,
            let redeemable = JSON["redeemable"] as? Bool,
            let redeemMethodStr = JSON["redeem_method"] as? String,
            let redeemMethod = RedeemMethod(rawValue: redeemMethodStr) else{
                return nil
        }
        self.id = id
        self.provider = provider
        self.name = name
        self.subtitle = subtitle
        self.description = description
        self.redeemable = redeemable
        self.redeemMethod = redeemMethod
        
        if let urlStr = JSON["image"] as? String,
            let url = URL(string: urlStr){
            self.imageURL = url
        }else{
            self.imageURL = nil
        }
        
        if let category_id = JSON["category_id"] as? String{
            self.categoryID = category_id
        }else{
            self.categoryID = nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let timing = JSON["timing"] as?  [String: Any]{
            
            if let start = timing["start_time"] as? String,
                let  startDate = dateFormatter.date(from: start){
                self.startDate = startDate
            }else{
                self.startDate = nil
            }
            
            if let expire = timing["expire_time"] as? String,
                let expiretDate = dateFormatter.date(from: expire){
                self.expirationDate = expiretDate
            }else{
                self.expirationDate = nil
            }
        }else{
            startDate = nil
            expirationDate = nil
        }
        
    }
}
