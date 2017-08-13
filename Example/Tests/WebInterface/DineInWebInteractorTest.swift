import UIKit
import XCTest
import MyCheckCore
@testable import MyCheckDine
@testable import WebInterface

class DineInWebInteractorTest : XCTestCase {
  
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
  
  
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure() {
      // Put the code you want to measure the time of here.
    }
  }
  
}
