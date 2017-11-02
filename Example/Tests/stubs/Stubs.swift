//
//  Stubs.swift
//  MyCheckDine
//
//  Created by elad schiller on 22/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
@testable import MyCheckDine
@testable import MyCheckWalletUI
@testable import MyCheckCore



extension Order{
  
  static func getStub() -> Order?{
    guard let validOrderJSON = getJSONFromFile( named: "orderDetails") , let order = Order(json: validOrderJSON) else{
      
      return nil;
    }
    return order
  }
}



extension CreditCardPaymentMethod {
  
  static func getStub() -> CreditCardPaymentMethod{
    
    return CreditCardPaymentMethod(for: .creditCard, name: "Elad", Id: "123", token: "abc", checkoutName: "checkout name")
  }
}



extension PaymentDetails{
  static func getPaymentDetailsStub() -> PaymentDetails?{
    
    guard let order = Order.getStub() else{
      return nil
    }
    
    
    let paymentDetails = PaymentDetails(order: order, amount: 1.0, tip: 0.5)
    
    return paymentDetails;
  }
}



fileprivate func getJSONFromFile(named name: String) -> [String:Any]? {
  let bundle = Bundle(for: DineInWebInteractorTest.self)
  guard let pathString = bundle.path(forResource: name, ofType: "json") else {
    fatalError("\(name) not found")
  }
  
  guard let jsonString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) else {
    fatalError("Unable to convert UnitTestData.json to String")
  }
  
  //  print("The JSON string is: \(jsonString)")
  
  guard let jsonData = jsonString.data(using: String.Encoding.utf8.rawValue) else {
    fatalError("Unable to convert UnitTestData.json to NSData")
  }
  
  guard let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject] else {
    fatalError("Unable to convert UnitTestData.json to JSON dictionary")
  }
  
  return jsonDictionary
}

extension Benefit{
    
   static func getBenefitStub() -> Benefit{
        let JSON: [String: Any] = [
            "id": "360304",
            "provider": "fishbowl",
            "name": "15% discount",
            "subtitle": "15% discount",
            "description": "15% discount",
            "redeemable": true,
            "redeem_method": "MANUAL",
            ]
        return Benefit(JSON: JSON)!
    }
}
