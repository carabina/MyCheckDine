// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import MyCheckCore
class ConfigureTest: QuickSpec {
    let net : RequestProtocol = Networking()
    
    override func spec() {
        describe("Testing configure function") {
            
            guard let validJSON = getJSONFromFile( named: "configure") else{
                expect("getJSONFromFile") == "success"
                return;
            }
           
            it("will configure successfully on valid response") {
                //Arrange
                //creating session and loading with mock object
                self.createNewValidConfiguredMockSession()
              
              //action
                Session.shared.configure("a key", environment: Environment.test)
                
                //Assert
                expect(Networking.shared.configureCalled).to(beTrue())
                expect(Networking.shared.configuredComplete).to(beTrue())
                
            }
            
            it("will not be configured if config was never called") {
                //Arrange
                Session.shared.dispose()

                //Act
                //cechking no action
                
                //Assert
                expect(Networking.shared.configureCalled).to(beFalse())
                expect(Networking.shared.configuredComplete).to(beFalse())
                
            }
           
            it("will know that configureCalled is true and that configuredComplete is false when the call fails due to lack of 'core' object") {
                //Arrange
                Session.shared.dispose()
                var inValidJSON = validJSON
                inValidJSON.removeValue(forKey: "core")
                Networking.shared.network = RequestProtocolMock(response: .success(inValidJSON))
                //Act
                Session.shared.configure("a key", environment: Environment.test)
           
                
                //Assert
                expect(Networking.shared.configureCalled).to(beTrue())
                expect(Networking.shared.configuredComplete).to(beFalse())
              
              
            }
          
          it("will know that configureCalled is true and that configuredComplete is false when the call fails due to lack of 'domain' strin in 'core' object") {
            //Arrange
            Session.shared.dispose()
            var inValidJSON = validJSON
            var coreJSON = inValidJSON["core"] as! [String:Any]
            coreJSON.removeValue(forKey: "Domain")
            inValidJSON["core"] = coreJSON
            
            Networking.shared.network = RequestProtocolMock(response: .success(inValidJSON))
            //Act
            Session.shared.configure("a key", environment: Environment.test)
            
            
            //Assert
            expect(Networking.shared.configureCalled).to(beTrue())
            expect(Networking.shared.configuredComplete).to(beFalse())
            
            
          }
        }
      
    }
  
  
  
  
    //MARK - private methods
    
}
