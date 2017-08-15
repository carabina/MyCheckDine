import UIKit
import XCTest
import MyCheckCore
@testable import MyCheckDine
@testable import WebInterface




class DineInWebInteractorTest : XCTestCase {
    
    class presenterSpy:  DineInWebPresentationLogic{
        
        var tableCodeResponse: DineInWeb.GetCode.Response?
        var pollToggleResponse: DineInWeb.Poll.Response?

        func presentTableCode(response: DineInWeb.GetCode.Response){
        tableCodeResponse = response
        }
        
        func orderUpdated(response: DineInWeb.GetCode.Response){
        
        }
    }
    
    
    var successGetCodeResponse: RequestProtocolMock? = nil
    var failGetCodeResponse: RequestProtocolMock? = nil
    
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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testCreatingADineInWebView() {
        var response: DineInWebViewController? = nil
        //Arrange
        self.createNewLoggedInSession()
        Dine.shared.network = successGetCodeResponse!
        let interactor = DineInWebInteractor()
        let request = DineInWeb.CreateDineIn.Request(BID: "2", displayDelegate: nil, applePayController: nil, success: {controller in
            response = controller
        }, fail: {error in
            XCTFail("should not fail here")
        })
        //Act
        interactor.createDineInWebViewController(request: request)
        //Assert
        XCTAssert(response !=  nil , "should have received a response")
    }
    
    func testFailingToCreatADineInWebView() {
        var response: NSError? = nil
        //Arrange
        self.createNewLoggedInSession()
        Dine.shared.network = failGetCodeResponse!
        let interactor = DineInWebInteractor()
        let request = DineInWeb.CreateDineIn.Request(BID: "2", displayDelegate: nil, applePayController: nil, success: {controller in
            XCTFail("should not succeed")
            
        }, fail: {error in
            response = error
        })
        //Act
        interactor.createDineInWebViewController(request: request)
        //Assert
        XCTAssert(response ==  ErrorCodes.badRequest.getError() , "should have received this error")
    }
    
    func testGetCodeSuccess() {
        
        //Arange
        let interactor = DineInWebInteractor()
        let spy = presenterSpy()
        interactor.tableCode = "1234"
        interactor.presenter = spy
       
        //Act
        interactor.getCodeRequested(request: DineInWeb.GetCode.Request(callback:"callback"))
        
        //Assert
      XCTAssert(  spy.tableCodeResponse?.code == "1234", "the code should be passed to the presenter")
        XCTAssert(  spy.tableCodeResponse?.callback == "callback", "callback should be passed on")

          }
    
    func testGetCodeFail() {
        
        //Arange
        let interactor = DineInWebInteractor()
        let spy = presenterSpy()
        interactor.presenter = spy
        
        //Act
        interactor.getCodeRequested(request: DineInWeb.GetCode.Request(callback: "callback"))
        //Assert
        XCTAssert(  spy.tableCodeResponse == nil, "the code shouldnt be passed to the presenter")
        XCTAssert(  spy.tableCodeResponse?.callback == "callback", "callback should be passed on")

    }
    
    
    func testTurnPollingOnAndOff() {
        
        //Arange
        self.createNewLoggedInSession()
        guard let validOrderJSON = getJSONFromFile( named: "orderDetails") , let validEmptyOrderJSON = getJSONFromFile( named: "orderDetailsNoItems") else{
            XCTFail("should not fail")

            return;
        }
        
        
       
        

        let interactor = DineInWebInteractor()
        let spy = presenterSpy()
        interactor.presenter = spy
        Dine.shared.network = RequestProtocolMock(response: .success(validOrderJSON))

        Dine.shared.poller.delayer = DelayMock(callback: { _ in
            interactor.toggleOrderDetailsPolling(request: DineInWeb.Poll.Request(pollingOn: false, callback: "callback"))
       })

        //Act
        interactor.toggleOrderDetailsPolling(request: DineInWeb.Poll.Request(pollingOn: true, callback: "callback"))
        //Assert
        switch  spy.pollToggleResponse!{
        case .success(let order):
            XCTAssert(order.stamp == "6ab19bb726a256246d41ee3566b88a21" , "the correct order was not passed")
        case .fail(let error):
            XCTFail("should not of failed")
        }
        
    }
    
    
}
