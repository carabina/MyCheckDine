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
    
    let amexRange = "3400 - 3499, 3700 - 3799"
    let jcbRange = "1800, 2131, 3500 - 3599"
    let dinersRange = "3000 - 3059, 3600 - 3699, 3800 - 3899"
    let maestroRange = "5018, 5020, 5038, 5612, 5893, 6304, 6390, 6759, 6761 - 6763, 6799"
    let unknownRange = "1000 - 1799, 1801 - 2130, 2132 - 2220, 2721 - 2999, 3060 - 3094, 3097 - 3399, 3900 - 3999, 5000 - 5017, 5019, 5021 - 5037, 5039 - 5099, 5600 - 5611, 5613 - 5892, 5894 - 6010, 6012 - 6219, 6230 - 6303, 6305 - 6389, 6391 - 6439, 6610 - 6758, 6760, 6764 - 6798, 6800 - 9999"
    let discoverRange = "3095 - 3096, 6011, 6220 - 6229, 6440 - 6609"
    let mastercardRange = "2221 - 2720, 5100 - 5599"
    let visaRange = "4000 - 4999"
    
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

fileprivate extension BinRangesTest{
    
    func printRanges(numberForTypes: [CreditCardType: [Int]]){
        
        for (type , array) in numberForTypes{
            let rangeStr = rangeString(for: array)
            print(type.rawValue + ": " + rangeStr + "\n")
            switch type.rawValue {
            case "amex":
                XCTAssert(rangeStr.replacingOccurrences(of: " ", with: "") == amexRange.replacingOccurrences(of: " ", with: ""), "")
                break
            case "jcb":
                XCTAssert(rangeStr.replacingOccurrences(of: " ", with: "") == jcbRange.replacingOccurrences(of: " ", with: ""), "")
                break
            case "diners":
                XCTAssert(rangeStr.replacingOccurrences(of: " ", with: "") == dinersRange.replacingOccurrences(of: " ", with: ""), "")
                break
            case "maestro":
                XCTAssert(rangeStr.replacingOccurrences(of: " ", with: "") == maestroRange.replacingOccurrences(of: " ", with: ""), "")
                break
            case "unknown":
                XCTAssert(rangeStr.replacingOccurrences(of: " ", with: "") == unknownRange.replacingOccurrences(of: " ", with: ""), "")
                break
            case "discover":
                XCTAssert(rangeStr.replacingOccurrences(of: " ", with: "") == discoverRange.replacingOccurrences(of: " ", with: ""), "")
                break
            case "mastercard":
                XCTAssert(rangeStr.replacingOccurrences(of: " ", with: "") == mastercardRange.replacingOccurrences(of: " ", with: ""), "")
                break
            case "visa":
                XCTAssert(rangeStr.replacingOccurrences(of: " ", with: "") == visaRange.replacingOccurrences(of: " ", with: ""), "")
                break
            default: break
                
            }
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
