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
    
    let paymentMethod = CreditCardPaymentMethod.getStub()
    
    let paymentDetails = PaymentDetails(order: order, amount: 1.0, tip: 0.5, paymentMethod: paymentMethod)
    
    return paymentDetails;
  }
}



fileprivate func getJSONFromFile(named name: String) -> [String:Any]? {
  let bundle = Bundle(for: Bundle(for: type(of: self)))
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
