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

@testable import MyCheckDine
import XCTest
@testable import MyCheckDineUIWeb
import MyCheckCore
@testable import MyCheckWalletUI


class DineInWebViewControllerSpy: DineInWebDisplayLogic{
    
    
    var JSString: String? = nil
    var displayApplePayViewModel: DineInWeb.DisplayApplePayViewController.ViewModel?
    func runJSOnWebview(viewModel: DineInWeb.ViewModel) {
        JSString = viewModel.JSToBeInjected
    }
    
    func displayApplePayViewController(viewModel: DineInWeb.DisplayApplePayViewController.ViewModel) {
        displayApplePayViewModel = viewModel
    }
    
}
class DineInWebPresenterTests: XCTestCase
{
    // MARK: Subject under test
    
    var presenter: DineInWebPresenter!
    var spy: DineInWebViewControllerSpy!
    
    //constants
    let callback = "callback"
    
    // MARK: Test lifecycle
    
    override func setUp()
    {
        super.setUp()
        setupDineInWebPresenter()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupDineInWebPresenter()
    {
        presenter = DineInWebPresenter()
        spy = DineInWebViewControllerSpy()
        presenter.viewController = spy
    }
    
    // MARK: Test doubles
    
    // MARK: Tests
    
    func testGetCode()
    {
        // Arrange
        
        let response = DineInWeb.GetCode.Response(code: "1234", callback: callback)
        // Act
        presenter.presentTableCode(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        let successJSON = createSuccessJSON(with: ["code": "1234"])
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON:successJSON ))
        
    }
    
    func testFailResponse()
    {
        // Arrange
        let error = ErrorCodes.badRequest.getError()
        let response = DineInWeb.FailResponse.init(error: error, callback: callback)
        // Act
        presenter.presentFailError(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        let failJSON = createFailJSON(with: error)
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON:failJSON ))
        
    }
    
    func testGetOrderDetails()
    {
        // Arrange
        guard var validOrderJSON = getJSONFromFile( named: "orderDetails")  else{
            XCTFail("failed to create test JSON")
            return
        }
        validOrderJSON.removeValue(forKey: "status")
        let response = DineInWeb.GetOrderDetails.Response(order: Order.getStub(), callback: callback)
        
        
        
        
        // Act
        presenter.gotOrder(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        guard let extractJSON = extractJSON(from: JS) else{
            XCTFail("could not get order JSON")
            return
        }
        
        XCTAssert(Order(json: extractJSON["body"] as! [String: Any]) != nil)
        
    }
    
    func testPollerSuccess()
    {
        // Arrange
        
        
        
        // Act
        presenter.orderUpdated(response: DineInWeb.Poll.Response.success(order: Order.getStub()!, callback: callback))
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        guard let extractJSON = extractJSON(from: JS) else{
            XCTFail("could not get order JSON")
            return
        }
        XCTAssert(Order(json: extractJSON["body"] as! [String: Any]) != nil)
        
        
    }
    
    func testPollerFail()
    {
        // Arrange
        
        
        
        // Act
        presenter.orderUpdated(response: DineInWeb.Poll.Response.fail(error: ErrorCodes.badRequest.getError(), callback: callback))
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        let failJSON = createFailJSON(with: ErrorCodes.badRequest.getError())
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON:failJSON ))
        
        
    }
    
    
    func testGotPaymentMethod()
    {
        // Arrange
        let paymetnMethod = CreditCardPaymentMethod(for: .creditCard, name: "Elad", Id: "123", token: "abc", checkoutName: "checkout name")
        let response = DineInWeb.PaymentMethods.Response(methods: [paymetnMethod], callback: callback)
        
        
        // Act
        presenter.gotPaymentMethods(response: response)
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        XCTAssert(JSISValid(JS: JS, callback: callback,
                            validJSON:createSuccessJSON(with: ["PaymentMethods":[paymetnMethod.generateJSON()]] )))
        
        
    }
    
    
    func testReorder()
    {
        // Arrange
        
        let response = DineInWeb.Reorder.Response(callback: callback)
        
        
        
        
        // Act
        presenter.reorderedItems(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        let emptyBody:[String:Any] = [:]
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON: createSuccessJSON(with: emptyBody)))
        
    }
    
    func testPay()
    {
        // Arrange
        let response = DineInWeb.Pay.Response(callback: callback , response: Dine.PaymentResponse(newBalance: 1, fullyPaid: false))
        
        // Act
        presenter.madePayment(response:  response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        let emptyBody:[String:Any] = ["fullyPaid":response.response.fullyPaid,
                                      "orderBalance": response.response.newBalance]
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON: createSuccessJSON(with: emptyBody)))
        
    }
    
    
    func testGetFriendsListTable()
    {
        // Arrange
        guard var validJSON = getJSONFromFile( named: "friendList") else {
            XCTFail("failed to create test JSON")
            return
        }
        
        guard let usersArray = validJSON["users"] as? [[String: Any]] else {
            XCTFail("failed to create test JSON")
            return
        }
        
        
        let friendsList = usersArray.map{DiningFriend(json: $0)}.flatMap{$0}
        let response = DineInWeb.GetFriendsList.Response( callback: callback, friends: [friendsList].flatMap{$0})
        
        
        // Act
        presenter.gotFriendList(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        XCTAssert(JSISValid(JS: JS, callback: callback,
                            validJSON:createSuccessJSON(with: ["users": usersArray] )))
    }
    
    
    func testAddFriendToOpenTable()
    {
        // Arrange
        let response = DineInWeb.AddAFriend.Response(callback: callback)
        
        
        // Act
        presenter.addedFriend(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        let emptyBody:[String:Any] = [:]
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON: createSuccessJSON(with: emptyBody)))
        
    }
    
    func testCallWaiter()
    {
        // Arrange
        let response = DineInWeb.CallWaiter.Response(callback: callback)
        
        
        // Act
        presenter.calledWaiter(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        let emptyBody:[String:Any] = [:]
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON: createSuccessJSON(with: emptyBody)))
        
    }
    
    func testSendFeedback()
    {
        // Arrange
        let response = DineInWeb.SendFeedback.Response(callback: callback)
        
        
        // Act
        presenter.sentFeedback(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        let emptyBody:[String:Any] = [:]
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON: createSuccessJSON(with: emptyBody)))
        
    }
    
    func testGetLocale()
    {
        // Arrange
        let response = DineInWeb.getLocale.Response(callback: callback, locale: NSLocale(localeIdentifier: "en_US"))
        
        
        // Act
        presenter.gotLocale(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        let emptyBody:[String:Any] = ["locale":response.locale.localeIdentifier]
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON: createSuccessJSON(with: emptyBody)))
        
    }
    
    
    func testGetBenefits()
    {
        // Arrange
        
        let benefits = [Benefit.getBenefitStub()]
        
        let response = DineInWeb.getBenefits.Response(callback: callback, benefits: benefits)
        
        // Act
        presenter.gotBenefits(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        XCTAssert(JSISValid(JS: JS, callback: callback,
                            validJSON:createSuccessJSON(with: ["benefits": benefits.map({$0.JSONify()})] )))
    }
    
    
    func testRedeemBenefit()
    {
        // Arrange
        let response = DineInWeb.RedeemBenefit.Response(callback: callback)
        
        
        // Act
        presenter.redeemedBenefits(response: response)
        
        // Assert
        guard let JS = spy.JSString else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
        let emptyBody:[String:Any] = [:]
        XCTAssert(JSISValid(JS: JS, callback: callback, validJSON: createSuccessJSON(with: emptyBody)))
        
    }
    
    func testDisplayApplePay(){
        
        // Arrange
        let response = DineInWeb.DisplayApplePayViewController.Response(viewController: UIViewController(), show: true)
        
        
        // Act
        presenter.displayApplePayViewController(response: response)
        
        // Assert
        guard let spyResponse = spy.displayApplePayViewModel else{
            XCTFail("should of recieved a call to viewcontroller")
            return
        }
        
      //Assert
      XCTAssert(spyResponse.show == response.show)
        XCTAssert(spyResponse.viewController == response.viewController)

        
        
    }
}





fileprivate extension DineInWebPresenterTests{
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
