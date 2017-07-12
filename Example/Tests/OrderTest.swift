// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import MyCheckCore
@testable import MyCheckDine

class OrderTest: QuickSpec {
    let net : RequestProtocol = Networking()
    
    override func spec() {
        describe("Testing order details function") {
            
            guard let validJSON = getJSONFromFile( named: "orderDetails") else{
                expect("getJSONFromFile") == "success"
                return;
            }
            
            it("will succeed on valid order without setting the order") {
                //Arrange
                self.createNewLoggedInSession()
                Dine.shared.network = RequestProtocolMock(response: .success(validJSON))
                //Act
                Dine.shared.getOrder(order: nil, success: { order in
                    guard let order = order else{
                        expect("not to fail") == "false"
                        return
                    }
                    expect(order) == Order(json: validJSON)
                    //Assert
                    expect(order.status.rawValue) == Status.open.rawValue
                    expect(order.restaurantId) == "2"
                    expect(order.clientCode) == "2070"
                    expect(order.orderId) == "47759"
                    expect(order.items.count) == 5
                    
                    expect(order.items[0].Id) == 920834
                    expect(order.items[0].name) == "BRUSCHETTA"
                    expect(order.items[0].price) == 4.95
                    expect(order.items[0].paid) == true
                    
                    expect(order.summary.balance) == 39.9
                    expect(order.summary.totalAmount) == 39.9
                    expect(order.summary.paidAmount) == 0.0
                    
                    expect(order.stamp) == "6ab19bb726a256246d41ee3566b88a21"
                    
                    
                    
                }, fail: {error in
                    expect("not to fail") == "false"
                })
            }
            
            
            
            it("will succeed on valid order while setting the order") {
                //Arrange
                self.createNewLoggedInSession()
                Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.noOrderUpdate.getError()))
                //Act
                Dine.shared.getOrder(order: Order(json: validJSON), success: { order in
                    guard let order = order else{
                        expect("not to fail") == "false"
                        return
                    }
                    //Assert
                    expect(order) == Order(json: validJSON)
                    
                    
                }, fail: {error in
                    expect("not to fail") == "false"
                })
            }
            
            
            it("will succeed on valid order while no open order") {
                //Arrange
                self.createNewLoggedInSession()
                Dine.shared.network = RequestProtocolMock(response: .fail(ErrorCodes.noOpenTable.getError()))
                //Act
                Dine.shared.getOrder(order: Order(json: validJSON), success: { order in
                   
                    expect(order) == nil
                    
                }, fail: {error in
                    expect("not to fail") == "false"
                })
            }

            
        }
 
    }
}
