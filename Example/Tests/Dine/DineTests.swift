//
//  DineTests.swift
//  MyCheckDine
//
//  Created by elad schiller on 8/20/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import MyCheckCore
@testable import MyCheckDine
class DineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        self.createNewLoggedInSession()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFriendListSuccess() {
        //Arrange
        guard let validJSON = getJSONFromFile( named: "friendList") else{
            XCTFail("test failed because JSON not working")
            return;
        }
        
        var paramsSent: RequestParameters? = nil
        Dine.shared.network = RequestProtocolMock(response: .success(validJSON)){ sent in
            paramsSent = sent
        }

        var response: [DiningFriend]? = nil
        //Act
        Dine.shared.getListOfFriendsAtOpenTable(success: {friends in
            response = friends
            
        }, fail: {error in
            XCTFail("should not fail")
            
        })
        
        //Assert
        guard let friends = response else {
            XCTFail("response should not be nil")
            
            return
        }
        XCTAssert(friends.count == 2)
        let friend = friends[1]
        
        XCTAssert(friend.ID == "1808853")
        XCTAssert(friend.firstName == "Fishbowlapp")
        XCTAssert(friend.lastName == "User")
        XCTAssert(friend.email == "1536@user.com")
        
        //checking the server call has the correct values
        XCTAssert( (paramsSent?.url.hasSuffix(URIs.friendList))!)
        XCTAssert( paramsSent?.method == .get)
    }
    
    func testFriendListFail() {
        //Arrange
        
        Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
        var response:NSError? = nil
        //Act
        Dine.shared.getListOfFriendsAtOpenTable(success: {friends in
            XCTFail("should not succeed")
            
        }, fail: {error in
            response = error
        })
        
        //Assert
        
        XCTAssert(response == ErrorCodes.badRequest.getError())
        
        
    }
    
    
    func testAddFriendSuccess() {
        //Arrange
        var success = false
        var paramsSent: RequestParameters? = nil
        Dine.shared.network = RequestProtocolMock(response: .success(["status":"OK"])){ sent in
            paramsSent = sent
        }
        
        //Act
        Dine.shared.addFriendToTable(friendCode: "1234", success: {
            success = true
        }, fail: {error in
            XCTFail("should not fail")
        })
        
        //Assert
        
        XCTAssert(success)
        
        //checking the server call has the correct values
        XCTAssert( (paramsSent?.url.hasSuffix(URIs.addFriend))!)
        XCTAssert( paramsSent?.method == .post)
        XCTAssert( paramsSent?.parameters!["code"] as! String == "1234")

    }
    
    
    func testAddFriendFail() {
        //Arrange
        
        Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
        var response:NSError? = nil
        //Act
        Dine.shared.addFriendToTable(friendCode: "1234", success: {
            XCTFail("should not succeed")
            
        }, fail: {error in
            response = error
        })
        
        //Assert
        
        XCTAssert(response == ErrorCodes.badRequest.getError())
        
        
    }
    
    
}
