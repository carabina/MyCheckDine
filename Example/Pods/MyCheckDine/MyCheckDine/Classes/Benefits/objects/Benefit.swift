//
//  Benefit.swift
//  MyCheckDine
//
//  Created by elad schiller on 11/1/17.
//

import Foundation



/// Reprisents a benefit
public class Benefit: BasicBenefit{
  
  
  /// The method the benefit can be redeemed by.
  ///
  /// - manual: In order to redeem redeem benefit must be called with this benefit
  /// - automatic: The benefit will be redeemed automatically when the condition will be met
  public enum RedeemMethod: String{
    
    case manual = "MANUAL"
    
    case automatic = "AUTO"
    
  }
  
  
  
  
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
  
  
  
  /// The method the benefit can be redeemed by (by calling the redeem function or automaticly)
  public let redeemMethod: RedeemMethod
  
  /// The date the benefit begins to be valid
  public let startDate: Date?
  
  /// The date the benefit expires
  public let expirationDate: Date?
  
  public override init?(JSON: [String: Any]){
    guard
      let name = JSON["name"] as? String,
      let subtitle = JSON["subtitle"] as? String,
      let description = JSON["description"] as? String,
      let redeemable = JSON["redeemable"] as? Bool,
      let redeemMethodStr = JSON["redeem_method"] as? String,
      let redeemMethod = RedeemMethod(rawValue: redeemMethodStr) else{
        return nil
    }
    
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
    super.init(JSON: JSON)
    
  }
  
  public func JSONify() -> [String: Any] {
    var JSON = ["id": id,
                "name": name,
                "subtitle": subtitle,
                "description": description,
                "redeemable": redeemable,
                "redeem_method": redeemMethod.rawValue,
                "provider": provider
      ] as [String : Any]
    if let imageURL = imageURL{
      JSON["image"] = imageURL
    }
    
    if startDate != nil || expirationDate != nil {
      
      var timing: [String: Any] = [:]
      
      if let startDate = startDate{
        timing["start_time"] = startDate
      }
      
      if let expirationDate = expirationDate{
        timing["expire_time"] = expirationDate
        
      }
      JSON["timing"] = timing
      
    }
    return JSON
  }
}

extension Benefit: Equatable{
    public static func ==(lhs: Benefit, rhs: Benefit) -> Bool {
       return lhs.name == rhs.name &&
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.subtitle == rhs.subtitle &&
        lhs.description == rhs.description &&
        lhs.redeemable == rhs.redeemable &&
        lhs.redeemMethod == rhs.redeemMethod &&
        lhs.provider == rhs.provider
    }
    
    
}
