//
//  NativeCallHandlerTests.swift
//  MyCheckDine
//
//  Created by elad schiller on 8/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import MyCheckDineUIWeb
@testable import MyCheckDine
@testable import MyCheckWalletUI
import MyCheckCore
import UIKit

class DineInWebViewControllerFactoryTests: XCTestCase {
    var controller: DineInWebViewController?
    
    var errorReturned: NSError?
    var successGetCodeResponse: RequestProtocolMock? = nil
    var failGetCodeResponse: RequestProtocolMock? = nil
    var controllerRecieved: DineInWebViewController? = nil
    
    override func setUp() {
        super.setUp()
        guard let validJSON = getJSONFromFile( named: "generateCode") else{
            XCTFail("cannot create success request")
            
            return;
        }
        
        successGetCodeResponse = RequestProtocolMock(response: .success(validJSON))
        
        failGetCodeResponse = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
        
    }
    
    override func tearDown() {
        errorReturned = nil
        successGetCodeResponse = nil
        failGetCodeResponse = nil
        controllerRecieved = nil
        super.tearDown()
    }
    
    func testCreatingADineInWebView() {
        //Arrange
        self.createNewLoggedInSession()
        Dine.shared.network = successGetCodeResponse!
        
        
        DineInWebViewControllerFactory.dineIn(at:"2", locale: NSLocale(localeIdentifier: "en_US"), delegate: self)
        //Assert
        XCTAssert(controllerRecieved !=  nil , "should have received a response")
        XCTAssert(errorReturned == nil , "should not have failed")
    }
    
    func testFailingToCreatADineInWebView() {
        //Arrange
        self.createNewLoggedInSession()
        Dine.shared.network = failGetCodeResponse!
        
        
        DineInWebViewControllerFactory.dineIn(at:"2", locale: NSLocale(localeIdentifier: "en_US"), delegate: self )
        //Assert
        
        XCTAssert(controllerRecieved ==  nil , "should have not received a response")
        XCTAssert(errorReturned == ErrorCodes.badRequest.getError() , "wrong errror passed or nil error")
        
    }
    
    
    
}

extension DineInWebViewControllerFactoryTests: DineInWebViewControllerDelegate{
    
    func dineInWebViewControllerCreatedSuccessfully(controller: UIViewController ){
        controllerRecieved = controller as! DineInWebViewController
    }
    
    func dineInWebViewControllerCreatedFailed(error: NSError ){
        errorReturned = error
    }
    func dineInWebViewControllerComplete(controller: UIViewController ,order:Order?, reason:DineInWebViewControllerCompletitionReason){
        //to-do
    }
    
}
