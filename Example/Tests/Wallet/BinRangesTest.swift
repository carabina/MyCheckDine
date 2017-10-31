//
//  BinRangesTest.swift
//  MyCheckDine_Tests
//
//  Created by elad schiller on 10/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import MyCheckWalletUI

class BinRangesTest: XCTestCase {
    
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        //Arrange
      
        
        var numbersForTypes : [CreditCardType: [Int]] = [CreditCardType.Amex:[],
                                                         CreditCardType.Diners:[],
                                                         CreditCardType.Discover:[],
                                                         CreditCardType.JCB:[],
                                                         CreditCardType.Maestro:[],
                                                         CreditCardType.MasterCard:[],
                                                         CreditCardType.Visa:[],
                                                         CreditCardType.Unknown:[]]
        
        for i in 1000 ... 9999{
            let validator = CreditCardValidator(cardNumber:String(i))
            if var array = numbersForTypes[validator.cardType]{
            array.append(i)
                numbersForTypes[validator.cardType] = array
            }
        }
     printRanges(numberForTypes: numbersForTypes)
    }
    
   
    
}

fileprivate extension  BinRangesTest{
    
    func printRanges(numberForTypes: [CreditCardType: [Int]]){
        
        for (type , array) in numberForTypes{
            let rangeStr = rangeString(for: array)
            print(type.rawValue + ": " + rangeStr + "\n")
            
        }
        
    }
    
    func rangeString(for array: [Int]) -> String{
        var toReturn = ""
        if array.count == 0 {
            return ""
        }
        
        var startRange = array[0]
        var endRange = startRange
        for number in array{
            if number - 1 > endRange {//close last range if it is not consecutive
                let rangeStr = rangeString(from: startRange, to: endRange)
                toReturn += toReturn.count == 0 ? rangeStr : ", " + rangeStr
                startRange = number
            }
            endRange = number

            
        }
        let rangeStr = rangeString(from: startRange, to: endRange)
        toReturn += toReturn.count == 0 ? rangeStr : ", " + rangeStr
        return toReturn
    }
    
    
    func rangeString(from start:Int, to end:Int) -> String{
        if start == end{
            
            return String(start)
        }
        return "\(start) - \(end)"
    }
}
