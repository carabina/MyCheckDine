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


@testable import MyCheckDineUIWeb

class NativeCallHandlerTests: XCTestCase {
    
    
    class InteractorSpy: DineInWebBusinessLogic{
        
        var setupRequest: DineInWeb.SetupDinein.Request?
        var getCodeRequest: DineInWeb.GetCode.Request?
        var pollRequest: DineInWeb.Poll.Request?
        var orderDetailsRequest: DineInWeb.GetOrderDetails.Request?
        var reorderRequest: DineInWeb.Reorder.Request?
        var paymentMethodsRequest: DineInWeb.PaymentMethods.Request?
        var payRequest: DineInWeb.Pay.Request?
        var completeRequest: DineInWeb.Complete.Request?
        func setupInteractor(request: DineInWeb.SetupDinein.Request){
            setupRequest = request
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
        
        func complete(request: DineInWeb.Complete.Request) {
         completeRequest = request
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
        
        
        
        DineInWebViewControllerFactory.dineIn(at: "2", locale: NSLocale(localeIdentifier: "en_US"), delegate: self)
        
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
  
  func testReorderSuccess() {
    //Arrange
    let spy = setAndReturnSpy()
    
    //Act
    runJSSynchronously(JSExpresion:"reorderItems();")
    
    //Assert
    XCTAssert(spy.reorderRequest?.callback == "itemsReordered")
    XCTAssert(spy.reorderRequest?.items.count == 1)
    XCTAssert(spy.reorderRequest?.items[0].item.quantity == 7)
    XCTAssert(spy.reorderRequest?.items[0].item.Id == 920836)
    XCTAssert(spy.reorderRequest?.items[0].item.name == "VEGETARIAN PIZZA")
    XCTAssert(spy.reorderRequest?.items[0].item.paid == false)
    XCTAssert(spy.reorderRequest?.items[0].item.price == 8.95)
    XCTAssert(spy.reorderRequest?.items[0].item.serialId == "994")
    XCTAssert(spy.reorderRequest?.items[0].amount == 7)

    
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
      
      XCTAssert(spy.payRequest?.tip == 0.5)

        XCTAssert(spy.payRequest?.paymentMethodId == "10405")

        XCTAssert(spy.payRequest?.paymentMethodType == .creditCard)

        XCTAssert(spy.payRequest?.paymentMethodToken == "I am a token")
      
      let payfor:DineInWeb.Pay.Request.PayFor = (spy.payRequest?.payFor)!
      
      switch payfor{
      
      case .amount(let amount):
        XCTAssert(amount == 1.1)
      
      case .items( _):
        XCTFail("should not have items")
        
      }
        
    }
    
    
    func testMakePaymentByItems() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"makePaymentByItem();")
        
        //Assert
        XCTAssert(spy.payRequest?.callback == "madePayment")
        XCTAssert(spy.payRequest?.tip == 0.5)
        
        XCTAssert(spy.payRequest?.paymentMethodId == "10405")
        
        XCTAssert(spy.payRequest?.paymentMethodType == .creditCard)
        
        XCTAssert(spy.payRequest?.paymentMethodToken == "I am a token")
        
      let payfor:DineInWeb.Pay.Request.PayFor = (spy.payRequest?.payFor)!
      
      switch payfor{
        
      case .amount(_):
        XCTFail("should not have amount")

      case .items( let items):
        XCTAssert(items.count == 2)
        XCTAssert(items[0].name == "VEGETARIAN PIZZA")
        XCTAssert(items[0].Id == 920836)
        XCTAssert(items[0].paid == false)
        XCTAssert(items[0].modifiers.count == 0)
        XCTAssert(items[0].quantity == 1)
        XCTAssert(items[0].price == 8.95)
        XCTAssert(items[0].serialId == "994")
        XCTAssert(items[0].showInReorder == true)
        XCTAssert(items[0].validForReorder == true)



      }

    }
    
    func testCompleteBecauseOfCompleteOrder() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"completeDineInOrderCompleted();")
        
        //Assert
        XCTAssert(spy.completeRequest?.callback == "completeFailed")
        guard let reason = spy.completeRequest?.reason else{
        XCTFail("missing reason or completion request")
            return
        }
        switch reason{
        case .completedOrder:
            break
        default: XCTFail("wrong reason type")
        }
        
        
    }
    
    func testCompleteBecauseOfCancel() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"completeDineInCanceled();")
        
        //Assert
        XCTAssert(spy.completeRequest?.callback == "completeFailed")
        guard let reason = spy.completeRequest?.reason else{
            XCTFail("missing reason or completion request")
            return
        }
        switch reason{
        case .canceled:
            break
        default: XCTFail("wrong reason type")
        }
        
        
    }
    
    func completeDineInOrderError() {
        //Arrange
        let spy = setAndReturnSpy()
        
        //Act
        runJSSynchronously(JSExpresion:"completeDineInCanceled();")
        
        //Assert
        XCTAssert(spy.completeRequest?.callback == "completeFailed")
        guard let reason = spy.completeRequest?.reason else{
            XCTFail("missing reason or completion request")
            return
        }
        switch reason{
        case .error(let error):
            XCTAssert(error.code == 21)
            XCTAssert(error.localizedDescription == "failed")

            break
        default: XCTFail("wrong reason type")
        }
        
        
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
