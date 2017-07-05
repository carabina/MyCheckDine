//
//  Session+mock.swift
//  MyCheckCore
//
//  Created by elad schiller on 14/06/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
@testable import MyCheckCore
import Quick
import Nimble
extension XCTestCase{
    
    /// Creates a session that is configured correctly
    ///
    /// - Returns: true if successfull
    @discardableResult
    func createNewValidConfiguredMockSession() ->Bool{
        guard let validJSON = getJSONFromFile( named: "configure") else{
            return false;
        }
        Session.shared.dispose()
        
        Networking.shared.network = RequestProtocolMock(response: .success(validJSON))
        
        Session.shared.configure("a key", environment: Environment.test)
        
        
        return true
    }
    
    func createNewLoggedInSession() {
        self.createNewValidConfiguredMockSession()
        guard let validJSON = getJSONFromFile( named: "login") else{
            expect("getJSONFromFile") == "success"
            return;
        }
        Networking.shared.network = RequestProtocolMock(response: .success(validJSON))
        
        Session.shared.login("refresh token", success: {
            expect(Session.shared.isLoggedIn()) == true
            
        }, fail: {error in
            expect("should not succes") == "but is here"
        })
    }
    
}

