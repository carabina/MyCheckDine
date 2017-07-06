// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import MyCheckCore
@testable import MyCheckDine

enum OrderPollerDelegateResponse : Matcher{
    
    typealias ValueType = OrderPollerDelegateResponse

    case update(Order?)
    case fail(NSError , Int)
    
    
    func doesNotMatch(_ other: Expression<OrderPollerDelegateResponse>, failureMessage: FailureMessage) throws -> Bool {
        switch (self , other.){
        case let (.update(a), .update(b)),
                  let (fail(a, numA), fail(b,numB)):
        default
            return false
        }
    }
    
    func matches(_ actualExpression: Expression<OrderPollerDelegateResponse>, failureMessage: FailureMessage) throws -> Bool {
        return false
    }

    
}
class LoginTest: QuickSpec {
    let net : RequestProtocol = Networking()
    
    //holds the last response sent by the poller delegate
    let pollerResponse:OrderPollerDelegateResponse? = nil
    
    override func spec() {
        describe("Testing poller functionality") {
            
            guard let validOrderJSON = getJSONFromFile( named: "orderDetails") , let validEmptyOrderJSON = getJSONFromFile( named: "orderDetails") else{
                expect("getJSONFromFile") == "success"
                return;
            }
            
            it("will call the update delegate method when an order is first recieved") {
                
                //Arrange
                self.createNewLoggedInSession()
                
                //an array with the mock response from the server and the expected result from the delegate
                let expectedResults : [(RequestProtocolMock , OrderPollerDelegateResponse?)] = [
                    //First time we get the
                    (RequestProtocolMock(response: .success(validOrderJSON)) , OrderPollerDelegateResponse.update(Order(json: validOrderJSON))),
                    //if we get no update nothing should happen
                    (RequestProtocolMock(response: .fail(ErrorCodes.noOrderUpdate.getError())),nil),
                     //if we get no update nothing should happen
                        (RequestProtocolMock(response: .fail(ErrorCodes.noOrderUpdate.getError())),nil),
                         //if we get for some reason the same order nothing should happen
                            (RequestProtocolMock(response: .success(validOrderJSON)),nil),
                            //if we get one fail nothing should happen
                            (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),nil),
                             //if we get two fails nothing should happen
                                (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),nil),
                                 //if we get three fails the fail callback should be caled
                                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),OrderPollerDelegateResponse.fail(ErrorCodes.badRequest.getError(), 3)),
                                     //if we get four fails the fail callback should be called
                                        (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),OrderPollerDelegateResponse.fail(ErrorCodes.badRequest.getError(), 4)),
                                         //testing that the counter is 0 again
                                            (RequestProtocolMock(response: .fail(ErrorCodes.noOrderUpdate.getError())),nil),
                                             //if we get one fail nothing should happen
                                                (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),nil),
                                                 //if we get two fails nothing should happen
                                                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),nil),
                                                     //if we get three fails the fail callback should be caled
                                                        (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),OrderPollerDelegateResponse.fail(ErrorCodes.badRequest.getError(), 3)),
                                                         //Order should be updated
                                                            (RequestProtocolMock(response: .success(validEmptyOrderJSON)) , OrderPollerDelegateResponse.update(Order(json: validEmptyOrderJSON))) ]
                var i = 0
                let request = expectedResults[i].0
                Networking.shared.network = request

                let poller = OrderPoller(delayer: DelayMock(callback: { _ in
                    
                    //Assert
                    if let expected = expectedResults[i].1{
                        if let actaul = self.pollerResponse{
                        expect(expected).to(equal(actaul))
                        }
                    }
                    expect(expectedResults[i].1).to(equal(pollerResponse))
                    if let expectedResult = expectedResults[i].1, let pollerResponse = self.pollerResponse{
                    expect(expectedResult) == pollerResponse
                    }else if let expectedResult = expectedResults[i].1{
                    expect(<#T##expression: T?##T?#>)
                    }
                    expect(pollerResponse) == expectedResults[i].1
                    // called before every order details callback
                    Networking.shared.network = request
                }))
                
                //act
                poller.startPolling()
                
                poller.delegate = self
                
                
            }
            
            it("will succeed on valid login") {
                //Arrange
                self.createNewValidConfiguredMockSession()
                Networking.shared.network = RequestProtocolMock(response: .success(validOrderJSON))
                //Act
                //action
                Session.shared.login("refresh token", success: {
                    expect(Session.shared.isLoggedIn()) == true
                }, fail: {error in
                    expect("should not succes") == "but is here"
                })
            }
            
            it("will succeed to logout after valid login") {
                //Arrange
                self.createNewValidConfiguredMockSession()
                Networking.shared.network = RequestProtocolMock(response: .success(validOrderJSON))
                //Act
                //action
                Session.shared.login("refresh token", success: {
                    expect(Session.shared.isLoggedIn()) == true
                    Session.shared.logout()
                    expect(Session.shared.isLoggedIn()) == false
                    
                }, fail: {error in
                    expect("should not succes") == "but is here"
                })
            }
            
            it("will fail to login when not getting a accessToken") {
                //Arrange
                self.createNewValidConfiguredMockSession()
                var invalidOrderJSON = validOrderJSON
                invalidOrderJSON.removeValue(forKey: "accessToken")
                Networking.shared.network = RequestProtocolMock(response: .success(invalidOrderJSON))
                //Act
                //action
                Session.shared.login("refresh token", success: {
                    expect("should not succes") == "but is here"
                    
                    
                }, fail: {error in
                    expect(error) == ErrorCodes.badJSON.getError()
                })
            }
            
            
        }
        
    }
    
    
    
}
//MARK - private methods
extension LoginTest : OrderPollerDelegate{
    func orderUpdated(order:Order?){
        pollerResponse = OrderPollerDelegateResponse.update(order)
    }
    
    func failingToReceiveUpdates(lastReceivedError: Error , failCount:Int){
        pollerResponse = OrderPollerDelegateResponse.fail(errno, failCount)
        
    }
    
}


