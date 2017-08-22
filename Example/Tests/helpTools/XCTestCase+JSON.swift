//
//  globalTestFunctions.swift
//  MyCheckCore
//
//  Created by elad schiller on 6/12/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase{
  
  internal func getJSONFromFile(named name: String) -> [String:Any]? {
    let bundle = Bundle(for: type(of: self))
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
}
