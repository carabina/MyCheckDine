//
//  NativeCallHandlerTests.swift
//  MyCheckDine
//
//  Created by elad schiller on 8/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import WebKit
@testable import MyCheckDine


@testable import WebInterface

class NativeCallHandlerTests: XCTestCase {
    
    
    class InteractorSpy: DineInWebBusinessLogic{
        
        var setupRequest: DineInWeb.SetupDinein.Request?
        var getCodeRequest: DineInWeb.GetCode.Request?
        var pollRequest: DineInWeb.Poll.Request?
        var orderDetailsRequest: DineInWeb.GetOrderDetails.Request?
        var reorderRequest: DineInWeb.Reorder.Request?
        var paymentMethodsRequest: DineInWeb.PaymentMethods.Request?
        var payRequest: DineInWeb.Pay.Request?
        
        func setupInteractor(request: DineInWeb.SetupDinein.Request){
            
        }
        
        
        //Requests from HTML
        func getCodeRequested(request: DineInWeb.GetCode.Request){
            getCodeRequest = request
        }
        
        func toggleOrderDetailsPolling(request: DineInWeb.Poll.Request){
            pollRequest = request
        }
        
        func getOrderDetails(request: DineInWeb.GetOrderDetails.Request){
            orderDetailsRequest = request
        }
        
        func reorderItems(request: DineInWeb.Reorder.Request){
            reorderRequest = request
        }
        
        func getPaymentMethods(request: DineInWeb.PaymentMethods.Request){
            paymentMethodsRequest = request
        }
        
        
        func makePayment(request: DineInWeb.Pay.Request){
            payRequest = request
        }
        
    }
    
    var controller: DineInWebViewController?
    var webViewLoadExpectation:XCTestExpectation?
    var window: UIWindow!
    
    
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        
        
        webViewLoadExpectation = expectation(description: "A controller will be created and the web view will load")
        
        
        self.createNewLoggedInSession()
        
        
        guard let validGetCodeJSON = getJSONFromFile( named: "generateCode") , let _ = getJSONFromFile( named: "orderDetailsNoItems") else{
            XCTFail("should not fail")
            
            return;
        }
        
        Dine.shared.network = RequestProtocolMock(response: .success(validGetCodeJSON))
        
        
        
        DineInWebViewControllerFactory.dineIn(at: "2", delegate: self)
        
        waitForExpectations(timeout: 2.2, handler: nil)
        
        
        // Issue an async request
        
        
    }
    
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    func testGenerateCode() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"callGenerateCode();")
        
        //Assert
        XCTAssert(spy.getCodeRequest?.callback == "receivedTableCode")
        
        
    }
    
    
    func testStartPolling() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"startPolling();")
        
        //Assert
        XCTAssert(spy.pollRequest?.callback == "startedPolling")
        
        XCTAssert(spy.pollRequest?.pollingOn == true)

    }
    
    func testStopPolling() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"stopPolling();")
        
        //Assert
        XCTAssert(spy.pollRequest?.callback == "stoppedPolling")
        XCTAssert(spy.pollRequest?.pollingOn == false)

        
    }
    
    func testGetOrderDetails() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"getOrderDetails();")
        
        //Assert
        XCTAssert(spy.orderDetailsRequest?.callback == "receivedOrder")
        
        
    }
    
    func testGetPaymentMethods() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"getPaymentMethods();")
        
        //Assert
        XCTAssert(spy.paymentMethodsRequest?.callback == "receivedPaymentMethods")
        
        
    }
    
    func testMakePaymentByAmount() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"makePaymentByAmount();")
        
        //Assert
        XCTAssert(spy.payRequest?.callback == "madePayment")
        XCTAssert(spy.payRequest?.amount == 1.1)
        XCTAssert(spy.payRequest?.tip == 0.5)

        XCTAssert(spy.payRequest?.paymentMethodId == "10405")

        XCTAssert(spy.payRequest?.paymentMethodType == .creditCard)

        XCTAssert(spy.payRequest?.paymentMethodToken == "I am a token")

        
    }
    
    
    func testMakePaymentByItems() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"makePaymentByItem();")
        
        //Assert
        XCTAssert(spy.payRequest?.callback == "madePayment")
        XCTAssert(spy.payRequest?.amount == 11.05)
        XCTAssert(spy.payRequest?.tip == 0.5)
        
        XCTAssert(spy.payRequest?.paymentMethodId == "10405")
        
        XCTAssert(spy.payRequest?.paymentMethodType == .creditCard)
        
        XCTAssert(spy.payRequest?.paymentMethodToken == "I am a token")
        
        
    }
    
}

//private methods
extension NativeCallHandlerTests{
    
    fileprivate func runJSSynchronously( JSExpresion:String){
        let JSExpectation = expectation(description: "JS must be run on the webview")
        
        self.controller?.webView?.evaluateJavaScript(JSExpresion,
                                                     completionHandler:{theID , error in
                                                        JSExpectation.fulfill()
                                                        
        })
        self.waitForExpectations(timeout: 0.1, handler: nil)
        
    }
    
    fileprivate func setAndReturnSpy() -> InteractorSpy{
        let spy = InteractorSpy()
        self.controller?.interactor = spy
        self.controller?.nativeCallHandler?.interactor = spy
        return spy
    }
}


extension NativeCallHandlerTests: WKNavigationDelegate{
    
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!){
        webViewLoadExpectation?.fulfill()
        
    }
    
}


extension NativeCallHandlerTests: DineInWebViewControllerDelegate{
    
    func dineInWebViewControllerCreatedSuccessfully(controller: UIViewController ){
        self.controller = controller as? DineInWebViewController
        window.addSubview(controller.view)
        self.controller?.webView?.navigationDelegate = self
        let bundle =  DineInWebViewController.getBundle( Bundle(for: DineInWebViewController.classForCoder()))
        
        let url = bundle.url(forResource: "test", withExtension: "html")
        // Initialize our NSURLRequest
        let request = URLRequest(url: url!)
        self.controller?.webView?.load(request)
    }
    
    func dineInWebViewControllerCreatedFailed(error: NSError ){}
    func dineInWebViewControllerComplete(controller: UIViewController ,order:Order?, reason:DineInWebViewControllerCompletitionReason){
        //to-do
    }
    
}

