//
//  order.swift
//  Pods
//
//  Created by elad schiller on 27/12/2016.
//
//

import UIKit
import Gloss


///Possible statuses of the order.
public enum Status: String {
  /// The order is open and outstanding.
  case open  = "Open"
  /// Sandbox environment. mimics the behaviour of the production environment but allows the use of test payment methods and user accounts.
  case closed = "Closed"
  /// The latest version of the Server code. The code will work with sandbox and test payment methods like the sandbox environment. It might have new untested and unstable code. Should not be used without consulting with a member of the MyCheck team first!
  case canceled = "Cancelled"
}



///Holds the information about the tax in the currant order.
 public struct BillSummary {
  ///The amount paid in total from the bill.
   public let paidAmount: Double
  ///The total of the bill.
   public let totalAmount: Double
  //The balance of the bill.
   public let balance: Double
  ///Information about the tax in the currant bill.
   public let tax : TaxInfo
  ///Information about the currant users payments in the bill.
   public let userSummary : UserSummary

  
  
  
  public  init?(json: JSON){
    guard let paidAmount: Double = "bill.global_summary.paid_amount" <~~ json else{
      return nil
    }
    self.paidAmount = paidAmount
    
    guard let totalAmount: Double = "bill.global_summary.total_amount" <~~ json else{
      return nil
    }
    self.totalAmount = totalAmount
  
    guard let balance: Double = "bill.global_summary.balance" <~~ json else{
      return nil
    }
    self.balance = balance
    guard let  tax : TaxInfo = TaxInfo.init(json: json) else{
    return nil
    }
    
    self.tax = tax
    
    guard let  userSummary : UserSummary = UserSummary.init(json: json) else{
      return nil
    }
    
    self.userSummary = userSummary

    
   
    
  }
}

///Holds information about the logged in users payments.
 public struct UserSummary {
  ///The amount already paid by the user.
   public let paidAmount: Double
  ///The amount of tip the user paid
   public let paidTip: Double
  
  public  init?(json: JSON){
    guard let paidAmount: Double = "bill.user_summary.paid_amount" <~~ json else{
      return nil
    }
    self.paidAmount = paidAmount
    
    guard let paidTip: Double = "bill.user_summary.paid_tip" <~~ json else{
      return nil
    }
    self.paidTip = paidTip
  }
}
///Holds the information about the tax in the currant order.
 public struct TaxInfo {
  ///The percentage of the total amount that must be charged as tax.
   public let percentage: Double
  ///The amount (in the currency the venue is using) of tax that must be charge.
   public let taxAmount: Double
  
  public  init?(json: JSON){
 
    guard let taxAmountStr: String = "bill.global_summary.tax_amount" <~~ json else{
     
      return nil
    }
    guard let taxAmount = Double( taxAmountStr) else{
    return nil
    }
   
    self.taxAmount = taxAmount
    
    guard let percentageStr: String = "tax_settings.percentage" <~~ json else{
      return nil
    }
    
    guard let percentage = Double( percentageStr) else{
      return nil
    }
    self.percentage = percentage
    
  }
}

///Represents an order in a venue. The order includes the orders status , bill information and some general information.
open class Order: Decodable {
  ///The Id of the order
   open let orderId : String
  /// The status of the order.
   open let status : Status
  ///The Id of the restaurant the order belongs to.
   open let restaurantId : String
  ///A summary of the orders bill.
   open let summary : BillSummary
  ///The date time the order was opened.
   open let openTime : Date
  ///The 4 digit code used by the client to connect to the POS.
   open let clientCode: String?
  ///wether or not this order is a quick service order (over the counter purchase)
  open let quickService: Bool
  
  ///The items ordered
 open let items : [Item]
  //The md5 of the order. used to check if the order was updated or not.
  internal var stamp: String
  public required init?(json: JSON) {
    
    guard let stamp: String = "stamp" <~~ json else{
      return nil
    }
    self.stamp = stamp
    
    guard let orderId: String = "order_id" <~~ json else{
    return nil
    }
    self.orderId = orderId
    
    guard let status: Status = "order_status" <~~ json else{
      return nil
    }
    self.status = status
  
  
  guard let restaurantId: String = "restaurant_id" <~~ json else{
  return nil
  }
  self.restaurantId = restaurantId
  
    
   let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    guard let openTime = Decoder.decode(dateForKey: "open_time", dateFormatter: dateFormatter)(json) else{
    return nil
    }
    self.openTime = openTime
   
    clientCode = "client_code" <~~ json
    
    if let quickService: Bool = "is_quick_service" <~~ json {
      self.quickService = quickService
    }else{
    self.quickService = false
    }
       guard let summary: BillSummary = BillSummary(json: json) else{
      return nil
    }
    self.summary = summary
  
    
    guard let items: [Item] = "items" <~~ json else{
      return nil
    }
    self.items = items
    
  }
  static func ==(lhs: Order, rhs: Order) -> Bool {
    return lhs.stamp == rhs.stamp
  }
  static func !=(lhs: Order, rhs: Order) -> Bool {
    return !(lhs.stamp == rhs.stamp)
  }

}
