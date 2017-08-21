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
        Dine.shared.getFriendsListAtOpenTable(success: {friends in
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
        Dine.shared.getFriendsListAtOpenTable(success: {friends in
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
        Dine.shared.addFriendToOpenTable(friendCode: "1234", success: {
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
        Dine.shared.addFriendToOpenTable(friendCode: "1234", success: {
            XCTFail("should not succeed")
            
        }, fail: {error in
            response = error
        })
        
        //Assert
        
        XCTAssert(response == ErrorCodes.badRequest.getError())
        
        
    }
    
    
    func testUserStatisticsSuccess() {
        //Arrange
        guard let validJSON = getJSONFromFile( named: "usageStats") else{
            XCTFail("test failed because JSON not working")
            return;
        }
        
        
        var stats: UserStatistics? = nil
        var paramsSent: RequestParameters? = nil
        Dine.shared.network = RequestProtocolMock(response: .success(validJSON)){ sent in
            paramsSent = sent
        }
        
        //Act
        Dine.shared.getUserStatistics(success: {recievedStats in
            stats = recievedStats
        }, fail: {error in
            XCTFail("should not fail")
            
        })
        //Assert
        
        XCTAssert(stats?.orderCount == 12)
        XCTAssert(stats?.averagePaidTotal == 10.1)
        XCTAssert(stats?.averagePaidTip == 5.8)
        XCTAssert(stats?.averageTimeAtTable == 5.1)
        XCTAssert(stats?.rewardsCount == 5)
        XCTAssert(stats?.favoritePlaceName == "Albany")
        XCTAssert(stats?.favoritePlaceVisitsCount == 5)
        XCTAssert(stats?.FavoriteItemPurchesCount == 100)
        
        //checking the server call has the correct values
        XCTAssert( (paramsSent?.url.hasSuffix(URIs.stats))!)
        XCTAssert( paramsSent?.method == .get)
        
        
        
    }
    
    
        func testUserStatisticsFail() {
            //Arrange
    
            Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
            var response:NSError? = nil
            //Act
             Dine.shared.getUserStatistics(success: { stats in
                XCTFail("should not succeed")
    
            }, fail: {error in
                response = error
            })
    
            //Assert
    
            XCTAssert(response == ErrorCodes.badRequest.getError())
            
            
        }
    
    
    
    func testPastOrderListSuccess() {
        //Arrange
        guard let validJSON = getJSONFromFile( named: "orderList") else{
            XCTFail("test failed because JSON not working")
            return;
        }
        
        
        var orders: [OrderHistoryItem]? = nil
        var paramsSent: RequestParameters? = nil
        Dine.shared.network = RequestProtocolMock(response: .success(validJSON)){ sent in
            paramsSent = sent
        }
        
        //Act
        Dine.shared.getOrderHistoryList( success: {pastOrders in
            orders = pastOrders
        }, fail: {error in
            XCTFail("should not fail")
            
        })
        //Assert
        
                XCTAssert(orders?.count == 7)
        XCTAssert(orders?[0].businessCurrency == "USD")
        XCTAssert(orders?[0].orderId == "49436")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date =  dateFormatter.date(from: "2017-08-19 21:44:29")
        XCTAssert(orders?[0].date == date)

        XCTAssert(orders?[0].businessName == "fishbowl-test")
        XCTAssert(orders?[0].paymentAmount == 1.1)


        //checking the server call has the correct values
        XCTAssert( (paramsSent?.url.hasSuffix(URIs.orderList))!)
        XCTAssert( paramsSent?.method == .get)
        
        
        
    }
    
    
    func testPastOrderListFail() {
        //Arrange
        
        Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.badRequest.getError()))
        var response:NSError? = nil
        //Act
        Dine.shared.getUserStatistics(success: { stats in
            XCTFail("should not succeed")
            
        }, fail: {error in
            response = error
        })
        
        //Assert
        
        XCTAssert(response == ErrorCodes.badRequest.getError())
        
        
    }
}
