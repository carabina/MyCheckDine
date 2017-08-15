import UIKit
import XCTest
import MyCheckCore
@testable import MyCheckDine
@testable import WebInterface
@testable import MyCheckWalletUI




class DineInWebInteractorTest : XCTestCase {
  
  class presenterSpy:  DineInWebPresentationLogic{
    
    var tableCodeResponse: DineInWeb.GetCode.Response?
    var pollToggleResponse: DineInWeb.Poll.Response?
    var getOrderResponse: DineInWeb.GetOrderDetails.Response?
    var reorderResponse: DineInWeb.Reorder.Response?
    var payResponse:  DineInWeb.Pay.Response?
    var paymentMethodsResponse: DineInWeb.PaymentMethods.Response?
    
    func presentTableCode(response: DineInWeb.GetCode.Response){
      tableCodeResponse = response
    }
    
    func orderUpdated(response: DineInWeb.Poll.Response){
      pollToggleResponse = response
    }
    
    func gotOrder(response: DineInWeb.GetOrderDetails.Response){
      getOrderResponse = response
    }
    
    func reorderedItems(response: DineInWeb.Reorder.Response){
      reorderResponse = response
    }
    
    func madePayment(response: DineInWeb.Pay.Response){
      payResponse = response
    }
    
    func gotPaymentMethods(response: DineInWeb.PaymentMethods.Response) {
      paymentMethodsResponse = response
    }
  }
  
  let callbackName = "callback"
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
    let (interactor , spy) = getInteractorWithPresenterSpy()
    interactor.model.tableCode = "1234"
    
    //Act
    interactor.getCodeRequested(request: DineInWeb.GetCode.Request(callback:callbackName))
    
    //Assert
    XCTAssert(  spy.tableCodeResponse?.code == "1234", "the code should be passed to the presenter")
    XCTAssert(  spy.tableCodeResponse?.callback == callbackName, "callback should be passed on")
    
  }
  
  func testGetCodeFail() {
    
    //Arange
    let (interactor , spy) = getInteractorWithPresenterSpy()

    //Act
    interactor.getCodeRequested(request: DineInWeb.GetCode.Request(callback: callbackName))
    //Assert
    XCTAssert(  spy.tableCodeResponse == nil, "the code shouldnt be passed to the presenter")
    
  }
  
  
  func testTurnPollingOnAndOff() {
    
    //Arange
    self.createNewLoggedInSession()
    guard let validOrderJSON = getJSONFromFile( named: "orderDetails") , let _ = getJSONFromFile( named: "orderDetailsNoItems") else{
      XCTFail("should not fail")
      
      return;
    }
    
    
    let (interactor , spy) = getInteractorWithPresenterSpy()

    Dine.shared.network = RequestProtocolMock(response: .success(validOrderJSON))
    
    Dine.shared.poller.delayer = DelayMock(callback: { _ in
      interactor.toggleOrderDetailsPolling(request: DineInWeb.Poll.Request(pollingOn: false, callback: self.callbackName))
    })
    
    //Act
    interactor.toggleOrderDetailsPolling(request: DineInWeb.Poll.Request(pollingOn: true, callback: callbackName))
    //Assert
    switch  spy.pollToggleResponse!{
    case .success(let order, let callback):
      XCTAssert(order.stamp == "6ab19bb726a256246d41ee3566b88a21" , "the correct order was not passed")
      XCTAssert(callback == callbackName, "callback was not passed properly")
    case .fail(_,_):
      XCTFail("should not of failed")
    }
    
  }
  
  func testGetOrderDetailsSuccess() {
    
    //Arange
    self.createNewLoggedInSession()
    guard let validOrderJSON = getJSONFromFile( named: "orderDetails") , let _ = getJSONFromFile( named: "orderDetailsNoItems") else{
      XCTFail("should not fail")
      
      return;
    }
    Dine.shared.network = RequestProtocolMock(response: .success(validOrderJSON))
    
    let (interactor , spy) = getInteractorWithPresenterSpy()

    //Act
    interactor.getOrderDetails(request: DineInWeb.GetOrderDetails.Request(callback: callbackName))
    
    //Assert
    switch  spy.getOrderResponse!{
    case .success(let order, let callback):
      XCTAssert(order?.stamp == "6ab19bb726a256246d41ee3566b88a21" , "the correct order was not passed")
      XCTAssert(  callback == callbackName, "callback should be passed on")
      
    case .fail( _, _):
      XCTFail("should not of failed")
      
    }
    
  }
  
  
  func testGetOrderDetailsFail() {
    
    //Arange
    self.createNewLoggedInSession()
    
    Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
    
    let (interactor , spy) = getInteractorWithPresenterSpy()

    //Act
    interactor.getOrderDetails(request: DineInWeb.GetOrderDetails.Request(callback: callbackName))
    
    //Assert
    switch  spy.getOrderResponse!{
    case .success( _, _):
      XCTFail("should not of succeed")
      
    case .fail(let error, let callback):
      assertFailedRequests(error: error, callback: callback)

      
    }
    
  }
  
  func testReorderFail() {
    
    //Arange
    self.createNewLoggedInSession()
    
    Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
    
    let (interactor , spy) = getInteractorWithPresenterSpy()

    let itemJSON: [String: Any] = [
      "id":920835,
      "name":"Tea",
      "price":1.8,
      "quantity":1,
      "paid":false,
      "serial_id":"9951",
      "valid_for_reorder":true,
      "show_in_reorder":true,
      "modifiers":[]
    ]
    
    
    guard let item =  Item(json: itemJSON)  else {
      XCTFail("item failed to create from JSON")
      return
    }
    //Act
    interactor.reorderItems(request: DineInWeb.Reorder.Request(callback: callbackName, items: [(2,item)]))
    
    //Assert
    switch  spy.reorderResponse!{
    case .success(_):
      XCTFail("should not of succeed")
      
    case .fail(let error, let callback):
      assertFailedRequests(error: error, callback: callback)

      
    }
    
  }
  
  
  func testReorderSuccess() {
    
    //Arange
    self.createNewLoggedInSession()
    
    Dine.shared.network = RequestProtocolMock(response: .success(["status":"OK"]))
    
    let (interactor , spy) = getInteractorWithPresenterSpy()

    let itemJSON: [String: Any] = [
      "id":920835,
      "name":"Tea",
      "price":1.8,
      "quantity":1,
      "paid":false,
      "serial_id":"9951",
      "valid_for_reorder":true,
      "show_in_reorder":true,
      "modifiers":[]
    ]
    
    
    guard let item =  Item(json: itemJSON)  else {
      XCTFail("item failed to create from JSON")
      return
    }
    //Act
    interactor.reorderItems(request: DineInWeb.Reorder.Request(callback: callbackName, items: [(2,item)]))
    
    //Assert
    switch  spy.reorderResponse!{
    case .success(let callback):
      
      XCTAssert(callback == callbackName, "callback was not passed properly")
      
    case .fail(_ , _):
      XCTFail("should not of fail")
    }
    
  }
  
  
  func testPaySuccess() {
    
    //Arange
    self.createNewLoggedInSession()
    
    Dine.shared.network = RequestProtocolMock(response: .success(["status":"OK"]))
    
    let (interactor , spy) = getInteractorWithPresenterSpy()

    //Act
    guard   let paymentDetails = getPaymentDetails() else{
      XCTFail("should not fail")
      return;
    }
    
    
    interactor.makePayment(request: DineInWeb.Pay.Request(callback: callbackName, paymentDetails: paymentDetails))
    
    //Assert
    switch  spy.payResponse!{
    case .success(let callback):
      
      XCTAssert(callback == callbackName, "callback was not passed properly")
      
    case .fail(_ , _):
      XCTFail("should not of fail")
    }
    
  }
  
  
  
  func testPayFail() {
    
    //Arange
    self.createNewLoggedInSession()
    
    Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
    
    let (interactor , spy) = getInteractorWithPresenterSpy()

    //Act
    guard   let paymentDetails = getPaymentDetails() else{
      XCTFail("should not fail")
      return;
    }
    
    
    interactor.makePayment(request: DineInWeb.Pay.Request(callback: callbackName, paymentDetails: paymentDetails))
    
    //Assert
    switch  spy.payResponse!{
    case .success(_):
      
      XCTFail("should not succeed")

    case .fail(let error , let callback):
      assertFailedRequests(error: error, callback: callback)


    }
    
  }
  
  
  func testGetPaymentMethodsSuccess() {
    
    //Arange
    self.createNewLoggedInSession()
    
    guard let validJSON = getJSONFromFile( named: "PaymentMethods") else{
      
      return ;
    }
  

    Wallet.shared.network = RequestProtocolMock(response: .success(validJSON))
    
    let (interactor , spy) = getInteractorWithPresenterSpy()
    
    //Act
    interactor.getPaymentMethods(request: DineInWeb.PaymentMethods.Request(callback:callbackName))
    
    //Assert
    switch  spy.paymentMethodsResponse!{
    case .success(let methods , let callback):
      XCTAssert(methods.count == 1, "callback was not passed properly")

      XCTAssert(callback == callbackName, "callback was not passed properly")
      
    case .fail(_ , _):
      XCTFail("should not of fail")
    }
    
  }
  
  
  func testGetPaymentMethodsFail() {
    
    //Arange
    self.createNewLoggedInSession()
    
    
    Wallet.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
    
    let (interactor , spy) = getInteractorWithPresenterSpy()
    
    //Act
    interactor.getPaymentMethods(request: DineInWeb.PaymentMethods.Request(callback:callbackName))
    
    //Assert
    switch  spy.paymentMethodsResponse!{
    case .success(_,_):
      
      XCTFail("should not of succeed")

    case .fail(let error , let callback):
      assertFailedRequests(error: error, callback: callback)
      

    }
    
  }
  
}
//helper methods that create stubs objects

extension DineInWebInteractorTest{
  
  fileprivate func assertFailedRequests(error: NSError, callback: String) {
    XCTAssert(callback == callbackName, "callback was not passed properly")
    XCTAssert(error == ErrorCodes.badRequest.getError(), "callback was not passed properly")
  }
  
  fileprivate func getInteractorWithPresenterSpy() -> (DineInWebInteractor , presenterSpy){
    let interactor = DineInWebInteractor()
    let spy = presenterSpy()
    interactor.presenter = spy
    return (interactor , spy)
  }
  
  fileprivate func getOrderDetails() -> Order?{
    guard let validOrderJSON = getJSONFromFile( named: "orderDetails") , let order = Order(json: validOrderJSON) else{
      
      return nil;
    }
    return order
  }
  
  fileprivate func getPaymentMethod() -> CreditCardPaymentMethod{
    
    return CreditCardPaymentMethod(for: .creditCard, name: "Elad", Id: "123", token: "abc", checkoutName: "checkout name")
  }
  
  fileprivate func getPaymentDetails() -> PaymentDetails?{
    
    guard let order = getOrderDetails() else{
      return nil
    }
    
    let paymentMethod = getPaymentMethod()
    
    let paymentDetails = PaymentDetails(order: order, amount: 1.0, tip: 0.5, paymentMethod: paymentMethod)
    
    return paymentDetails;
  }
  
}

