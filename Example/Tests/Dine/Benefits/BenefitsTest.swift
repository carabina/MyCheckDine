//
//  BenefitsTest.swift
//  MyCheckDine_Tests
//
//  Created by elad schiller on 11/1/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import MyCheckDine
import MyCheckCore
@testable import MyCheckDineUIWeb
class BenefitsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        self.createNewLoggedInSession()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBenefitListSuccess() {
    
        
        //Arrange
        var paramsSent: RequestParameters? = nil

        guard let validJSON = getJSONFromFile( named: "benefits") else{
            XCTFail("test failed because JSON not working")
            return;
        }

        Benefits.network = RequestProtocolMock(response: .success(validJSON)){ sent in
            paramsSent = sent
        }
        
        let bid = "123ef"
        var benefitsOptionl: [Benefit]? = nil

        //Act
        Benefits.getBenefits(restaurantId: bid, success: { benefitsRecieved in
            benefitsOptionl = benefitsRecieved
            
        }, fail: {error in
            XCTFail("success should of been called")
            
        })
        
        //Assert
        guard let benefits = benefitsOptionl else{
            XCTFail("benefit should not be nil nor empty")
            return
        }
        XCTAssert(paramsSent?.method == .get)
        XCTAssert(paramsSent?.parameters!["businessId"] as! String == bid)
        XCTAssert((paramsSent?.url.hasSuffix(URIs.getBenefits))!)

        let benefit = benefits[0]
        XCTAssert(benefits.count == 3 )
        XCTAssert(benefit.id == "1" )
        XCTAssert(benefit.provider == "2" )
        XCTAssert(benefit.name == "3" )
        XCTAssert(benefit.subtitle == "4" )
        XCTAssert(benefit.description == "5" )
        XCTAssert(benefit.redeemable == true )
        XCTAssert(benefit.imageURL == nil )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date =  dateFormatter.date(from: "2017-04-01 08:15:30")
        
        XCTAssert(benefit.startDate == date )
        XCTAssert(benefit.expirationDate == date )


    }
    
    func testBenefitListFail() {
        
        
        //Arrange
        var paramsSent: RequestParameters? = nil
        
       
        
        Benefits.network =  RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())){ sent in
            paramsSent = sent
        }
        
        let bid = "123ef"
        var error: NSError? = nil
        
        //Act
        Benefits.getBenefits(restaurantId: bid, success: { benefitsRecieved in
            XCTFail("fail should of been called")

        }, fail: {errorReturned in
            error = errorReturned
        })
        
        //Assert
        
        XCTAssert(paramsSent?.method == .get)
        XCTAssert((paramsSent?.url.hasSuffix(URIs.getBenefits))!)

        XCTAssert(paramsSent?.parameters!["businessId"] as! String == bid)
        
        XCTAssert(error == ErrorCodes.badRequest.getError() )
        
    }
    
    
    func testRedeemBenefitFail(){
        //Arrange
        var paramsSent: RequestParameters? = nil
        
        guard let validJSON = getJSONFromFile( named: "redeemFail") else{
            XCTFail("test failed because JSON not working")
            return;
        }
        
        Benefits.network = RequestProtocolMock(response: .success(validJSON)){ sent in
            paramsSent = sent
        }
        
        let bid = "123ef"
        let expectedError = NSError(domain: "12", code: 12003, userInfo:  [NSLocalizedDescriptionKey : "MINIMUM_PURCHASE_AMOUNT"])
        var optionalError : NSError? = nil
        let benefit = Benefit.getBenefitStub()
        //Act
        Benefits.redeem(benefit: benefit, restaurantId: bid,  success: { benefitsRecieved in
            XCTFail("fail should of been called")

        }, fail: {recievedError in
            optionalError = recievedError
        })
        
        //Assert
       
        XCTAssert(paramsSent?.method == .post)
        XCTAssert(paramsSent?.parameters!["businessId"] as! String == bid)
        XCTAssert((paramsSent?.url.hasSuffix(URIs.redeemBenefits))!)
        
        guard let error = optionalError else{
            XCTFail("no error recieved")
return
        }
        XCTAssert(error.code == expectedError.code )
        XCTAssert(error.localizedDescription == expectedError.localizedDescription )

        
    }

    
    func testRedeemBenefitSuccess(){
        //Arrange
        var paramsSent: RequestParameters? = nil
        
        guard let validJSON = getJSONFromFile( named: "redeemSuccess") else{
            XCTFail("test failed because JSON not working")
            return;
        }
        
        Benefits.network = RequestProtocolMock(response: .success(validJSON)){ sent in
            paramsSent = sent
        }
        
        let bid = "123ef"
        var success: Bool = false
        let benefit = Benefit.getBenefitStub()
        //Act
        Benefits.redeem(benefit: benefit, restaurantId: bid,  success: { benefitsRecieved in
            success = true
            
        }, fail: {error in
            XCTFail("success should of been called")
            
        })
        
        //Assert
        
        XCTAssert(paramsSent?.method == .post)
        XCTAssert(paramsSent?.parameters!["businessId"] as! String == bid)
        XCTAssert((paramsSent?.url.hasSuffix(URIs.redeemBenefits))!)
        
        guard let benefitsJSONString = paramsSent?.parameters!["benefits"]as? String,
        let benefitsJSONArray = benefitsJSONString.JSONStringToJSONArray()
        else{
            XCTFail("benefit parsing failed")

            return
        }
        XCTAssert( benefitsJSONArray.count == 1)
     
        let benefitsSummerayJSON = benefitsJSONArray[0]
        XCTAssert( benefitsSummerayJSON["id"] as? String == benefit.id)
        XCTAssert( benefitsSummerayJSON["provider"] as? String == benefit.provider)

        XCTAssert(success == true )
        
        
    }

}




