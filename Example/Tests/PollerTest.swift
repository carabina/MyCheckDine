// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import MyCheckCore
@testable import MyCheckDine

enum OrderPollerDelegateResponse : Equatable{
    
    typealias ValueType = OrderPollerDelegateResponse
    
    case update(Order?)
    case fail(NSError , Int)
    
    
    
    public static func ==(lhs: OrderPollerDelegateResponse, rhs: OrderPollerDelegateResponse) -> Bool{
        switch (lhs , rhs){
        case let (.update(a), .update(b)):
            return optionalsAreEqual(firstVal: a, secondVal: b)
        case let (.fail(a, numA), .fail(b,numB)):
            return a == b && numA == numB
        default:
            return false
        }
    }
    
    
    
    
}
class PollerTest: QuickSpec {
    let net : RequestProtocol = Networking()
    
    //holds the last response sent by the poller delegate
    var pollerResponse:OrderPollerDelegateResponse? = nil
    
    override func spec() {
        describe("Testing poller functionality") {
            
            guard let validOrderJSON = getJSONFromFile( named: "orderDetails") , let validEmptyOrderJSON = getJSONFromFile( named: "orderDetailsNoItems") else{
                expect("getJSONFromFile") == "success"
                return;
            }
            
            it("will call the update delegate method when an order is first recieved") {
                
                //Arrange
                self.createNewLoggedInSession()
                
                //an array with the mock response from the server and the expected result from the delegate
                let requestAndExpectedResult : [(RequestProtocolMock , OrderPollerDelegateResponse?)] = [
                    //0 First time we get the
                    (RequestProtocolMock(response: .success(validOrderJSON)) , OrderPollerDelegateResponse.update(Order(json: validOrderJSON))),
                    //1 if we get no update nothing should happen
                    (RequestProtocolMock(response: .fail(ErrorCodes.noOrderUpdate.getError())),nil),
                    //2 if we get no update nothing should happen
                    (RequestProtocolMock(response: .fail(ErrorCodes.noOrderUpdate.getError())),nil),
                    //3 if we get for some reason the same order nothing should happen
                    (RequestProtocolMock(response: .success(validOrderJSON)),nil),
                    //4 if we get one fail nothing should happen
                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),nil),
                    //5 if we get two fails nothing should happen
                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),nil),
                    //6 if we get three fails the fail callback should be called
                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),OrderPollerDelegateResponse.fail(ErrorCodes.badRequest.getError(), 3)),
                    //7 if we get four fails the fail callback should be called
                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),OrderPollerDelegateResponse.fail(ErrorCodes.badRequest.getError(), 4)),
                    //8 testing that the counter is 0 again
                    (RequestProtocolMock(response: .fail(ErrorCodes.noOrderUpdate.getError())),nil),
                    //9 if we get one fail nothing should happen
                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),nil),
                    //10 if we get two fails nothing should happen
                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),nil),
                    //11 if we get three fails the fail callback should be caled
                    (RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError())),OrderPollerDelegateResponse.fail(ErrorCodes.badRequest.getError(), 3)),
                    //12 Order should be updated
                    (RequestProtocolMock(response: .success(validEmptyOrderJSON)) , OrderPollerDelegateResponse.update(Order(json: validEmptyOrderJSON))) ]
                var i = 0
                let request = requestAndExpectedResult[i].0
                Dine.shared.network = request
                
                let poller = OrderPoller()
                poller.delayer = DelayMock(callback: { _ in
                    print("running test #\(i)")
                    //Assert
                    let expected: OrderPollerDelegateResponse? = requestAndExpectedResult[i].1
                    if let expectedResult = expected, let pollerResponse = self.pollerResponse{
                        expect(expectedResult) == pollerResponse
                    }else if let _ = expected{
                        expect("poller response") == "not to be nil"
                    }else if let _ = self.pollerResponse{
                        expect("poller response") == "to be nil"
                    }
                    
                    //removing response for next call to delay
                    self.pollerResponse = nil
                    // called before every order details callback
                    i += 1
                    
                    if i >= requestAndExpectedResult.count{
                        // ending test
                        poller.stopPolling()
                    }else{
                        Dine.shared.network = requestAndExpectedResult[i].0

                    }
                })

                //act
                poller.delegate = self
                
                poller.startPolling()
                
                
                
            }
            
            
            
        }
        
    }
    
    
    
}
//MARK - private methods
extension PollerTest : OrderPollerDelegate{
    func orderUpdated(order:Order?){
        pollerResponse = OrderPollerDelegateResponse.update(order)
    }
    
    func failingToReceiveUpdates(lastReceivedError: Error , failCount:Int){
        pollerResponse = OrderPollerDelegateResponse.fail((lastReceivedError as? NSError)!, failCount)
        
    }
    
}

func optionalsAreEqual<T: Equatable>(firstVal: T?, secondVal: T?) -> Bool{
    
    if let firstVal = firstVal, let secondVal = secondVal {
        return firstVal == secondVal
    }
    else{
        return firstVal == nil && secondVal == nil
    }
}

