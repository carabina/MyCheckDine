import UIKit
import XCTest
import MyCheckCore
@testable import MyCheckDine
@testable import MyCheckDineUIWeb
@testable import MyCheckWalletUI




class DineInWebInteractorTest : XCTestCase {
    
    class presenterSpy:  DineInWebPresentationLogic{
   
        var tableCodeResponse: DineInWeb.GetCode.Response?
        var pollToggleResponse: DineInWeb.Poll.Response?
        var getOrderResponse: DineInWeb.GetOrderDetails.Response?
        var reorderResponse: DineInWeb.Reorder.Response?
        var generatePaymentRequestResponse: DineInWeb.GeneratePayRequest.Response?
        var payResponse:  DineInWeb.Pay.Response?
        var paymentMethodsResponse: DineInWeb.PaymentMethods.Response?
        var failedResponse: DineInWeb.FailResponse?
        var completeResponse: DineInWeb.Complete.Response?
        var friendListResponse: DineInWeb.GetFriendsList.Response?
        var addFriendResponse: DineInWeb.AddAFriend.Response?
        var feedbackResponse: DineInWeb.SendFeedback.Response?
        var callWaiterResponse: DineInWeb.CallWaiter.Response?
        var getLocaleResponse: DineInWeb.getLocale.Response?
        var getBenefitsResponse: DineInWeb.getBenefits.Response?
        var redeemedBenefitsResponse:DineInWeb.RedeemBenefit.Response?
        var displayApplePayViewControllerResponse: DineInWeb.DisplayApplePayViewController.Response?
        
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
        
        func generatedPaymentRequest(response: DineInWeb.GeneratePayRequest.Response) {
            generatePaymentRequestResponse = response
        }
        
        func madePayment(response: DineInWeb.Pay.Response){
            payResponse = response
        }
        
        func gotPaymentMethods(response: DineInWeb.PaymentMethods.Response) {
            paymentMethodsResponse = response
        }
        
        func presentFailError(response: DineInWeb.FailResponse) {
            failedResponse = response
        }
        
        func complete(response: DineInWeb.Complete.Response) {
            completeResponse = response
        }
        
        func gotFriendList(response: DineInWeb.GetFriendsList.Response){
            friendListResponse = response
        }
        
        func addedFriend(response: DineInWeb.AddAFriend.Response){
            addFriendResponse = response
        }
        
        func sentFeedback(response: DineInWeb.SendFeedback.Response){
            feedbackResponse = response
        }
        
        func calledWaiter(response: DineInWeb.CallWaiter.Response){
            callWaiterResponse = response
        }
        
        func gotLocale(response: DineInWeb.getLocale.Response){
            getLocaleResponse = response
            
        }
        
        func gotBenefits(response: DineInWeb.getBenefits.Response){
            getBenefitsResponse = response
        }
        
        func redeemedBenefits(response: DineInWeb.RedeemBenefit.Response) {
            redeemedBenefitsResponse = response
        }
        
        func displayApplePayViewController(response: DineInWeb.DisplayApplePayViewController.Response) {
            displayApplePayViewControllerResponse = response
        }
    }
    
    let callbackName = "callback"
    
    
    override func setUp() {
        super.setUp()
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
        guard var validOrderJSON = getJSONFromFile( named: "orderDetails") , let _ = getJSONFromFile( named: "orderDetailsNoItems") else{
            XCTFail("should not fail")
            
            return;
        }
        validOrderJSON["stamp"] = "9804w39874398743"
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        
        Dine.shared.network = RequestProtocolMock(response: .success(validOrderJSON))
        
        Dine.shared.pollerManager .delayer = DelayMock(callback: { _ in
            interactor.toggleOrderDetailsPolling(request: DineInWeb.Poll.Request(pollingOn: false, callback: self.callbackName))
        })
        
        //Act
        interactor.toggleOrderDetailsPolling(request: DineInWeb.Poll.Request(pollingOn: true, callback: callbackName))
        //Assert
        switch  spy.pollToggleResponse!{
        case .success(let order, let callback):
            XCTAssert(order.stamp == "9804w39874398743" , "the correct order was not passed")
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
        interactor.getOrderDetails(request: DineInWeb.GetOrderDetails.Request(callback: callbackName, cache: false))
        
        //Assert
        
        XCTAssert(spy.getOrderResponse!.order?.stamp == "6ab19bb726a256246d41ee3566b88a21" , "the correct order was not passed")
        XCTAssert(  spy.getOrderResponse!.callback == callbackName, "callback should be passed on")
        
        
        
    }
    
    
    func testGetOrderDetailsFail() {
        
        //Arange
        self.createNewLoggedInSession()
        
        Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        
        //Act
        interactor.getOrderDetails(request: DineInWeb.GetOrderDetails.Request(callback: callbackName , cache: false))
        
        //Assert
        assertFailedResponse(response: spy.failedResponse)
        
        
        
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
        XCTAssert( spy.reorderResponse == nil)
        assertFailedResponse(response: spy.failedResponse)
        
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
        
        XCTAssert(spy.reorderResponse?.callback == callbackName, "callback was not passed properly")
        
        
        XCTAssert(spy.failedResponse == nil)
        
    }
    
    
    
    func testGeneratePaymentRequestByItemsSuccess() {
        
        //Arange
        self.createNewLoggedInSession()
        var sentRequest: RequestParameters? = nil
      Dine.shared.network = RequestProtocolMock(response: .success(getPaymentRequestJSON(amount: 2.12)) ,
                                                  callback:{ params in
                                                    sentRequest = params
        }
        )
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        interactor.model.order = getOrderDetails()
        let paymentMethod = getPaymentMethod()
        interactor.model.paymentMethods = [paymentMethod]
        
        let itemJSON :[String:Any] = [
            "id":920836,
            "name":"VEGETARIAN PIZZA",
            "price":5.1,
            "quantity":2,
            "paid":false,
            "serial_id":"994",
            "valid_for_reorder":true,
            "show_in_reorder":true,
            "modifiers":[]
        ]
        let item = Item(json: itemJSON)
        let items = [item] as! [Item]
        let payFor = DineInWeb.GeneratePayRequest.Request.PayFor.items(items)
        let request =  DineInWeb.GeneratePayRequest.Request(callback: callbackName, payFor:payFor, tip: 0.5)
        
        //Act
        
        
        interactor.callGeneratePaymentRequest(request:request)
        
        let response =  spy.generatePaymentRequestResponse
        //Assert
        
        
        
        XCTAssert(spy.failedResponse == nil)
        
        XCTAssert(response?.callback == callbackName, "callback was not passed properly")
        XCTAssert((sentRequest?.url.hasSuffix(URIs.generatePaymentRequest))!)
        XCTAssert(sentRequest?.method == .get)
        
        XCTAssert(response?.totalBeforeTax == 1.02)
        XCTAssert(response?.totalAfterTax == 2.12)
        XCTAssert(response?.totalTax == 1.1)
        XCTAssert(response?.isExceedingTableTotalAmount == false)


    }
    
    
    func testPaySuccess() {
        
        //Arange
        self.createNewLoggedInSession()
        var sentRequest: RequestParameters? = nil
        
        Dine.shared.network = RequestProtocolMock(response: .success(["status":"OK" , "orderBalance":1.12 , "fullyPaid":false]),
                                                  callback:{ params in
                                                    sentRequest = params
        }
        )
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        interactor.model.order = getOrderDetails()
        let paymentMethod = getPaymentMethod()
        let paymentRequest = getPaymentRequest()
        interactor.model.paymentMethods = [paymentMethod]
        interactor.model.paymentRequest = paymentRequest
        //Act
        
        interactor.makePayment(request: DineInWeb.Pay.Request(callback: callbackName,  tip: 0.5, paymentMethodId:paymentMethod.ID, paymentMethodToken: "abc"    , paymentMethodType: paymentMethod.type))
        
        let response  = spy.payResponse
        
        //Assert
        XCTAssert(spy.failedResponse == nil)
        
        XCTAssert(response?.callback == callbackName, "callback was not passed properly")
        XCTAssert((sentRequest?.url.hasSuffix(URIs.payment))!)
        XCTAssert(sentRequest?.method == .post)
        XCTAssert(sentRequest?.parameters!["amount"] as! Double == paymentRequest.total)
        XCTAssert(sentRequest?.parameters!["tip"] as! String == "0.50")
        XCTAssert(sentRequest?.parameters!["ccToken"] as! String == "abc")
        XCTAssert(response?.response.newBalance == 1.12)
        XCTAssert(response?.response.fullyPaid == false)
        
        
    }
    
    
    
    func testPayFail() {
        
        //Arange
        self.createNewLoggedInSession()
        
        Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        interactor.model.order = getOrderDetails()
        let paymentMethod = getPaymentMethod()
        interactor.model.paymentMethods = [paymentMethod]
        
        
        //Act
        interactor.model.paymentRequest = getPaymentRequest()
        
        
        interactor.makePayment(request: DineInWeb.Pay.Request(callback: callbackName, tip: 0.5, paymentMethodId:paymentMethod.ID, paymentMethodToken: "abc"    , paymentMethodType: paymentMethod.type))
        
        //Assert
        XCTAssert(spy.payResponse == nil)
        
        
        assertFailedResponse(response: spy.failedResponse)
        
        
        
        
        
    }
    func testFeedbackSuccess() {
        
        //Arange
        
        var paramsSent: RequestParameters? = nil
        Dine.shared.network = RequestProtocolMock(response:  .success(["status":"OK"])){ sent in
            paramsSent = sent
        }
        
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        let starsGiven = 1
        let comment = "whats up doc?"
        //Act
        interactor.sendFeedback(request: DineInWeb.SendFeedback.Request(callback: callbackName, orderId: "1234", stars: starsGiven, comment: comment))
        
        //Assert
        XCTAssert(  spy.feedbackResponse?.callback == callbackName, "callback should be passed on")
        
        XCTAssert(paramsSent?.parameters?["stars"] as? Int == starsGiven)
        XCTAssert(paramsSent?.parameters?["comments"] as? String == comment)
        XCTAssert( (paramsSent?.url.hasSuffix(URIs.sendFeedback))!)
        XCTAssert( paramsSent?.method == .post)
        
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
        let methods = spy.paymentMethodsResponse?.methods
        let callback = spy.paymentMethodsResponse?.callback
        XCTAssert(methods?.count == 1, "callback was not passed properly")
        
        XCTAssert(callback == callbackName, "callback was not passed properly")
        
        
        XCTAssert(spy.failedResponse == nil)
        
    }
    
    
    func testGetPaymentMethodsFail() {
        
        //Arange
        self.createNewLoggedInSession()
        
        
        Wallet.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        
        //Act
        interactor.getPaymentMethods(request: DineInWeb.PaymentMethods.Request(callback:callbackName))
        
        //Assert
        XCTAssert(spy.paymentMethodsResponse == nil)
        
        assertFailedResponse(response: spy.failedResponse)
        
        
        
        
    }
    
    func testComplete() {
        //to-do
        //        //Arange
        //        let (interactor , spy) = getInteractorWithPresenterSpy()
        //        interactor.model.tableCode = "1234"
        //
        //        //Act
        //        interactor.getCodeRequested(request: DineInWeb.GetCode.Request(callback:callbackName))
        //
        //        //Assert
        //        XCTAssert(  spy.tableCodeResponse?.code == "1234", "the code should be passed to the presenter")
        //        XCTAssert(  spy.tableCodeResponse?.callback == callbackName, "callback should be passed on")
        
    }
    
    
    func testGetLocale(){
        
        
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        //Act
        interactor.getLocale(request: DineInWeb.getLocale.Request(callback: callbackName))
        
        //Assert
        XCTAssert(  spy.getLocaleResponse?.callback == callbackName, "callback should be passed on")
        
    }
    
    func testGetBenefits(){
        
        //Arange
        self.createNewLoggedInSession()
        guard let validOrderJSON = getJSONFromFile( named: "benefits") else{
            XCTFail("should not fail")
            
            return;
        }
        Benefits.network = RequestProtocolMock(response: .success(validOrderJSON))
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        let restaurantId = "123"
        //Act
        interactor.getBenefits(request: DineInWeb.getBenefits.Request(callback: callbackName, restaurantId: restaurantId))
        
        //Assert
        
        XCTAssert(spy.getBenefitsResponse!.benefits.count == 3)
        XCTAssert(spy.getBenefitsResponse!.benefits[0].id == "1")

        XCTAssert(  spy.getBenefitsResponse!.callback == callbackName, "callback should be passed on")
        
        
        
    }
    
    func testRedeemBenefits(){
        
        //Arange
        self.createNewLoggedInSession()
        guard let validOrderJSON = getJSONFromFile( named: "redeemSuccess") else{
            XCTFail("should not fail")
            
            return;
        }
        Benefits.network = RequestProtocolMock(response: .success(validOrderJSON))
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        let restaurantId = "123"
        let benefit = Benefit.getBenefitStub()
        //Act
        interactor.redeemBenefits(request: DineInWeb.RedeemBenefit.Request(callback: callbackName, restaurantId: restaurantId, benefit: benefit))
        
        //Assert
        
    
        XCTAssert(  spy.redeemedBenefitsResponse!.callback == callbackName, "callback should be passed on")
        
        
        
    }
    
    func testDisplayApplePay(){
        
        //Arange
        self.createNewLoggedInSession()
      
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
 
        let controller =  UIViewController()
        //Act
        interactor.display(viewController:controller)
        
        //Assert
        
        XCTAssert(  spy.displayApplePayViewControllerResponse?.show == true)
        XCTAssert(  spy.displayApplePayViewControllerResponse?.viewController == controller)

        
    }
    func testDismissApplePay(){
        
        //Arange
        self.createNewLoggedInSession()
        
        
        let (interactor , spy) = getInteractorWithPresenterSpy()
        
        let controller =  UIViewController()
        //Act
        interactor.dismiss(viewController:controller)
        
        //Assert
        
        XCTAssert(  spy.displayApplePayViewControllerResponse?.show == false)
        XCTAssert(  spy.displayApplePayViewControllerResponse?.viewController == controller)
        
        
    }
    
}
//helper methods that create stubs objects

extension DineInWebInteractorTest{
    
    fileprivate func assertFailedResponse(response: DineInWeb.FailResponse?) {
        guard let response = response else{
            XCTFail("No fail response recieved")
            return
        }
        self.assertFailedResponse(error: response.error, callback: response.callback)
    }
    
    
    fileprivate func assertFailedResponse(error: NSError, callback: String) {
        XCTAssert(callback == callbackName, "callback was not passed properly")
        XCTAssert(error == ErrorCodes.badRequest.getError(), "callback was not passed properly")
    }
    
    
    
    fileprivate func getInteractorWithPresenterSpy() -> (DineInWebInteractor , presenterSpy){
        let interactor = DineInWebInteractor()
        interactor.model.locale = NSLocale(localeIdentifier: "en_US")
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
  fileprivate func getPaymentRequestJSON(amount: Double) -> [String:Any]{
    let totalTax = 1.1
    let subtotal = amount - totalTax
    let taxList:[[String:Any]] =  [
      [
        "name": "Tax1",
        "amount": 1.33,
        "isInclusive": true
      ],
      [
        "name": "Tax2",
        "amount": 0.0,
        "isInclusive": false
      ],
      [
        "name": "Tax3",
        "amount": 0.0,
        "isInclusive": false
      ],
      [
        "name": "Tax4",
        "amount": 0.0,
        "isInclusive": false
      ]
    ]
   return ["totalTax": totalTax , "priceBeforeTax": subtotal , "priceAfterTax": amount,
                                    "taxList": taxList]
    
  }
    fileprivate func getPaymentRequest() -> PaymentRequest{
      let amount = 11.1

       let order = getOrderDetails()
        let paymentDetails = PaymentDetails(order: order!, amount: amount, tip: 1)
      
    let validJSON = getPaymentRequestJSON(amount: amount)
      return PaymentRequest(paymentDetails: paymentDetails, json: validJSON)!
    }
    
    
    fileprivate func getPaymentDetails() -> PaymentDetails?{
        
        guard let order = getOrderDetails() else{
            return nil
        }
        
        
        let paymentDetails = PaymentDetails(order: order, amount: 1.0, tip: 0.5)
        
        return paymentDetails;
    }
    
}

