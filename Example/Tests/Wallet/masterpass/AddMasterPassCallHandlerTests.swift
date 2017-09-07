    //
    //  NativeCallHandlerTests.swift
    //  MyCheckDine
    //
    //  Created by elad schiller on 8/16/17.
    //  Copyright © 2017 CocoaPods. All rights reserved.
    //
    
    import XCTest
    import WebKit
    import MyCheckCore
    @testable import MyCheckWalletUI
    
    
    class AddMasterPassCallHandlerTests: XCTestCase {
        
        
        class InteractorSpy: AddMasterPassBusinessLogic{
            
            var getTokenRequest: AddMasterPass.GetMasterpassToken.Request?
            var addMasterPassRequest: AddMasterPass.AddMasterpass.Request?
            
            func setup(request:AddMasterPass.Setup.Request){
            
            }
            
            func getMasterpassToken(request:AddMasterPass.GetMasterpassToken.Request){
                getTokenRequest = request
            }
            
            
            func addMasterpass(request: AddMasterPass.AddMasterpass.Request){
                addMasterPassRequest = request
            }
            
            
            
            
        }
        
        var controller: AddMasterPassViewController?
        var webViewLoadExpectation:XCTestExpectation?
        var window: UIWindow!
        
        
        
        override func setUp() {
            super.setUp()
            window = UIWindow()
            
            
            webViewLoadExpectation = expectation(description: "A controller will be created and the web view will load")
            
            
            self.createNewLoggedInSession()
            
            let response: [String: Any] = ["status":"Ok",
                                           "merchantCheckoutID":"id",
                                           "token":"token"]
            
            
            Wallet.shared.network = RequestProtocolMock(response: .success(response))
            
            
            
            
            let factory = MasterPassFactory()
            MasterPassFactory.initiate()
            factory.delegate = self
            factory.getAddMethodViewControllere()
            
            
            waitForExpectations(timeout: 2.2, handler: nil)
            
            
            // Issue an async request
            
            
        }
        
        
        override func tearDown() {
            window = nil
            super.tearDown()
        }
        
        
        
//        func testgetMasterpassToken(){
//            //Arrange
//            let spy = setAndReturnSpy()
//            
//            //Act
//            runJSSynchronously(JSExpresion:"getMasterpassToken();")
//            
//            //Assert
//            XCTAssert(spy.getTokenRequest?.callback == "callback")
//            
//            
//            
//            
//        }
        
//        func testAddMasterpassSuccess(){
//            //Arrange
//            let spy = setAndReturnSpy()
//            var payloadOption: String? = nil
//            //Act
//            runJSSynchronously(JSExpresion:"addMasterpassSuccess();")
//            
//            //Assert
//            //to-do test response
//            switch spy.addMasterPassRequest!.complitionStatus {
//            case .success(let payloadResponse):
//                payloadOption = payloadResponse
//            default:
//                XCTFail("should of succeeded")
//            }
//            
//            guard let payload = payloadOption else{
//                XCTFail("should of succeeded")
//                
//                return
//            }
//            
//            XCTAssert(payload == "payload")
//            
//            
//            
//            
//        }
        
//        func testAddMasterpassFail(){
//            //Arrange
//            let spy = setAndReturnSpy()
//            var errorOptional: NSError? = nil
//            //Act
//            runJSSynchronously(JSExpresion:"addMasterpassFail();")
//            
//            //Assert
//            //to-do test response
//            
//            switch spy.addMasterPassRequest!.complitionStatus {
//            case .failed(let errorResonse):
//                errorOptional = errorResonse
//            default:
//                XCTFail("should of failed")
//            }
//            
//            guard let error = errorOptional else{
//                XCTFail("should of failed")
//                
//                return
//            }
//            
//            XCTAssert(error.code == 1)
//            XCTAssert(error.localizedDescription == "error")
//            
//            
//            
//            
//        }
//        
        
//        func testAddMasterpassCancel(){
//            //Arrange
//            let spy = setAndReturnSpy()
//            var cancelled = false
//            //Act
//            runJSSynchronously(JSExpresion:"addMasterpassCancelled();")
//            
//            //Assert
//            //to-do test response
//            
//            switch spy.addMasterPassRequest!.complitionStatus {
//            case .cancelled:
//                cancelled = true
//            default:
//                XCTFail("should of cancelled")
//            }
//            
//          
//            
//            XCTAssert(cancelled)
//            
//            
//            
//            
//        }
    }
    
    //private methods
    extension AddMasterPassCallHandlerTests{
        
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
    
    
    extension AddMasterPassCallHandlerTests: WKNavigationDelegate{
        
        func webView(_ webView: WKWebView,
                     didFinish navigation: WKNavigation!){
            webViewLoadExpectation?.fulfill()
            
        }
        
    }
    
    extension AddMasterPassCallHandlerTests: PaymentMethodFactoryDelegate{
        
        func error(_ controller: PaymentMethodFactory , error:NSError){
            
        }
        func addedPaymentMethod(_ controller: PaymentMethodFactory ,method:PaymentMethodInterface , message:String?){
            
        }
        func displayViewController(_ controller: UIViewController ){
            self.controller = controller as? AddMasterPassViewController
            
            window.addSubview(controller.view)
            self.controller?.webView?.navigationDelegate = self
            let bundle = Bundle(for: type(of: self))
            
            let url = bundle.url(forResource: "testMasterPass", withExtension: "html")
            // Initialize our NSURLRequest
            let request = URLRequest(url: url!)
            self.controller?.webView?.load(request)
        }
        
        func dismissViewController(_ controller: UIViewController ){
            
        }
        func showLoadingIndicator(_ controller: PaymentMethodFactory ,show: Bool){
            
        }
        //askes the delegate if to add the payment method for single use or not
        func shouldBeSingleUse(_ controller: PaymentMethodFactory) -> Bool{
            return false
        }
    }
    
