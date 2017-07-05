// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import MyCheckCore
@testable import MyCheckDine
class LoginTest: QuickSpec {
    let net : RequestProtocol = Networking()
    
    override func spec() {
        describe("Testing poller functionality") {
            
            guard let validJSON = getJSONFromFile( named: "orderDetails") else{
                expect("getJSONFromFile") == "success"
                return;
            }
            
            it("will call the delegate when an order is first recieved") {
                //Arrange
                createNewLoggedInSession()
                
               let poller = OrderPoller()
                
            }
            
            it("will succeed on valid login") {
                //Arrange
                self.createNewValidConfiguredMockSession()
                Networking.shared.network = RequestProtocolMock(response: .success(validJSON))
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
                Networking.shared.network = RequestProtocolMock(response: .success(validJSON))
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
                var invalidJSON = validJSON
                invalidJSON.removeValue(forKey: "accessToken")
                Networking.shared.network = RequestProtocolMock(response: .success(invalidJSON))
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
    
    
    
    
    //MARK - private methods
    
}
