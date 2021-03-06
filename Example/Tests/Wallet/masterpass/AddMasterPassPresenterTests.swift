//
//  DineInWebPresenterTests.swift
//  MyCheckDine
//
//  Created by elad schiller on 8/16/17.
//  Copyright (c) 2017 CocoaPods. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import XCTest
import MyCheckCore
@testable import MyCheckWalletUI


class AddMasterPassViewControllerSpy: AddMasterPassDisplayLogic{
    var JSString: String? = nil
    
    func runJSOnWebview(viewModel: AddMasterPass.ViewModel) {
        JSString = viewModel.JSToBeInjected
    }
    
    func complete(viewModel: AddMasterPass.AddMasterpass.ViewModel){
    
    }
    
}
class AddMasterPassPresenterTests: XCTestCase
{
    // MARK: Subject under test
    
    var presenter: AddMasterPassPresenter!
    var spy: AddMasterPassViewControllerSpy!
    
    //constants
    let callback = "callback"
    
    // MARK: Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupAddMasterPassPresenter()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func setupAddMasterPassPresenter()
    {
        presenter = AddMasterPassPresenter()
        spy = AddMasterPassViewControllerSpy()
        presenter.viewController = spy
    }

    
    // MARK: Tests
    
//    func testGetMasterpassToken()
//    {
//            // Arrange
//        
//        let response = AddMasterPass.GetMasterpassToken.Response(callback: callback,
//                                                                 payload: MasterPassInitPayload(token:"token", merchantCheckoutID:"merchantCheckoutID"))
//        
//        // Act
//            presenter.getMasterpassToken(response: response)
//        
//            // Assert
//            guard let JS = spy.JSString else{
//            XCTFail("should of recieved a call to viewcontroller")
//              return
//            }
//            let successJSON =  ["token": "token",
//                                                       "merchantCheckoutID": "merchantCheckoutID"]
//            XCTAssert(JSISValid(JS: JS, callback: callback, validJSON:successJSON ))
//        
//    }
    
    
    func testAddMasterpass()
    {
        // Arrange
        
//        let response = AddMasterPass.AddMasterpass.Response(callback: callback)
//        
//        // Act
//        presenter.addedMasterpass(response: response)
//        
//        // Assert
//        guard let JS = spy.JSString else{
//            XCTFail("should of recieved a call to viewcontroller")
//            return
//        }
//        let emptyBody:[String:Any] = [:]
//        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON:emptyBody ))
        
    }
    
    func testFailResponse()
    {
        // Arrange
//        let error = ErrorCodes.badRequest.getError()
//        let response = AddMasterPass.FailResponse.init(error: error, callback: callback)
//        // Act
//        presenter.presentFailError(response: response)
//        
//        // Assert
//        guard let JS = spy.JSString else{
//            XCTFail("should of recieved a call to viewcontroller")
//            return
//        }
//        let failJSON = createFailJSON(with: error)
//        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON:failJSON ))
        
    }
    
    }





fileprivate extension AddMasterPassPresenterTests{
    func JSISValid(JS: String, callback:String, validJSON:[String:Any]?) -> Bool{
        
        guard let JSON = extractJSON(from: JS) else{
            return false
        }
        
        guard let validJSON = validJSON else{
            return false
        }
        let VALIDSTRINGIFY = validJSON.stringify()
        print(VALIDSTRINGIFY!)
        print("\n\n\n\n\n")
        print(JS)
        return  NSDictionary(dictionary: JSON).isEqual(to: validJSON)
        
        
        
    }
    
    func extractJSON(from JS:String) ->[String:Any]?{
        let split1 =  JS.components(separatedBy: "(")
        
        
        if split1.count != 2{
            return nil
        }
        let callback1 = split1[0]
        if callback1 != callback{
            return nil
        }
        let split2 = split1[1].components(separatedBy: ")")
        
        if split2.count != 2 {
            return nil
        }
        
        let JSONStr = split2[0]
        
        guard let JSON = JSONStr.JSONStringToDictionary() else{
            return nil
        }
        return JSON
    }
    
    func createSuccessJSON(with body: [String:Any]) -> [String: Any] {
        let toReturn: [String: Any] = ["errorCode":0,
                                       "body": body]
        return toReturn
    }
    
    func createFailJSON(with error: NSError) -> [String: Any] {
        let toReturn: [String: Any] = ["errorCode":error.code,
                                       "errorMessage": error.localizedDescription]
        return toReturn
    }
}

public extension String{
    
    
    func JSONStringToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

