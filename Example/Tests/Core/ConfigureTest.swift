// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import MyCheckCore
@testable import MyCheckDine


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
            
            it("will know that configureCalled is true and that configuredComplete is false when the call fails due to lack of 'config' object") {
                //Arrange
                Session.shared.dispose()
                var inValidJSON = validJSON
                inValidJSON.removeValue(forKey: "config")
                Networking.shared.network = RequestProtocolMock(response: .success(inValidJSON))
                //Act
                Session.shared.configure("a key", environment: Environment.test)
                
                
                //Assert
                expect(Networking.shared.configureCalled).to(beTrue())
                expect(Networking.shared.configuredComplete).to(beFalse())
                
                
            }
            
                      
            it("will respond to all the listenres when 1 call succeeds and not call the server again") {
                //Arrange
                Networking.shared.dispose()
                Session.shared.dispose()
                var step = 0
                let request = RequestProtocolMock(response: .success(validJSON) , respondImmediately: false)
                Networking.shared.network = request
                Session.shared.configure("a key", environment: Environment.test)
                
                //Act
                Networking.shared.configure(success: {JSON in
                    step += 1
                    expect(step) == 5
                    
                }, fail: {error in
                    expect("not to fail") == "false"
                })
                step += 1
                
                expect(step) == 1
                Networking.shared.configure(success: {JSON in
                    step += 1
                    expect(step) == 6
                    
                }, fail: {error in
                    expect("not to fail") == "false"
                    
                })
                step += 1
                expect(step) == 2
                
                
                Networking.shared.configure(success: {JSON in
                    step += 1
                    expect(step) == 7
                    
                }, fail: {error in
                    expect("not to fail") == "false"
                    
                })
                step += 1
                expect(step) == 3
                
                
                Networking.shared.configure(success: {JSON in
                    step += 1
                    expect(step) == 8
                    
                }, fail: {error in
                    expect("not to fail") == "false"
                    
                })
                step += 1
                expect(step) == 4
                
                request.respond()
                
                //Assert
                expect(step) == 8
                
                
            }
        }
        
    }
    
    
    
    
    //MARK - private methods
    
}
