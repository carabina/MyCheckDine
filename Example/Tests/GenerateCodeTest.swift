// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import MyCheckCore
@testable import MyCheckDine

class GeneratCodeTest: QuickSpec {
    let net : RequestProtocol = Networking()
    
    override func spec() {
        describe("Testing order generate code function") {
            
            guard let validJSON = getJSONFromFile( named: "generateCode") else{
                expect("getJSONFromFile") == "success"
                return;
            }
            
            it("will succeed on a valid response") {
                //Arrange
                self.createNewLoggedInSession()
                Dine.shared.network = RequestProtocolMock(response: .success(validJSON))
                //Act
                Dine.shared.generateCode(hotelId: "f", restaurantId: "f", success: { code in
                    
                    //Assert
                    expect(code) == "1234"
                    
                }, fail: {error in
                    expect("not to fail") == "false"
                    
                })
                
            }
            
            
            
            it("will fail if no code is supplied") {
                //Arrange
                self.createNewLoggedInSession()
                var invalidJSON = validJSON
                invalidJSON.removeValue(forKey: "code")
                Dine.shared.network = RequestProtocolMock(response: .success(invalidJSON))
                //Act
                Dine.shared.generateCode(hotelId: "f", restaurantId: "f", success: { code in
                    
                    //Assert
                    expect("not to succeed") == "false"
                    
                }, fail: {error in
                    expect(error) == ErrorCodes.badJSON.getError()
                    
                })
                
            }
            
            
            
        }
        
    }
}
