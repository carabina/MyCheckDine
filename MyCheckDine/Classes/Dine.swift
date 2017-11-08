import Foundation
import MyCheckCore


internal struct URIs{
    
    static let reorder = "/restaurants/api/v1/reorder"
    static let generateCode = "/restaurants/api/v1/generateCode"
    static let orderDetails = "/restaurants/api/v1/order"
    static let payment = "/restaurants/api/v1/payment"
    static let friendList = "/restaurants/api/v1/friendsList"
    static let addFriend = "/restaurants/api/v1/addFriend"
    static let stats = "/restaurants/api/v1/usageStats"
    static let orderList = "/restaurants/api/v1/orderList"
    static let callWaiter = "/restaurants/api/v1/callWaiter"
    static let sendFeedback = "/restaurants/api/v1/feedback"
  static let generatePaymentRequest = "/restaurants/api/v1/prepaidCalculation"

    
}

///Dine is a singleton That encapsulates the MyCheck dine in proccess: from opening a table , through getting the order details and reordering items to paying for the order.
public class Dine: NSObject{
    internal static let refreshPaymentMethodsNotification = "com.mycheck.refreshPaymentMethodsNotification"
    
    
    
    private static var _shared  :Dine? = Dine()
    
    ///This property points to the singleton object. It should be used for calling all the functions in the class.
    public class var shared: Dine
    {
        if let singleton = _shared
        {
            
            return singleton
        }
        _shared = Dine()
        return _shared!
    }
    
    //Used for session managment and calling server.
    internal var network: RequestProtocol = Networking.shared;
    
    
    internal override init() {
        super.init()
        Networking.shared.configure(success: { JSON in
            if let dineConfig = JSON["dine"] as? [String:Any], let intervalNum = dineConfig["pollingInterval"] as? NSNumber{
                let interval = intervalNum.doubleValue
                if interval > 0 {
                    self.pollerManager.pollingInterval = interval
                }
            }
        }, fail: nil)
        
    }
    //When activated this object polls the MyCheck server in order to fetch order updates. Call The startPolling function and set the delegate in order to receive updates. You should generally start useing the poller  when a 4 digit code is created until the order is closed or canceled.
    internal var pollerManager = OrderPollerManager()
 
    
    /// Creates a new order poller. When activated this object polls the MyCheck server in order to fetch order updates. Make sure to hold a reference to the returned object for as long as you want it to send you order update events.
    ///
    /// - Parameter delegate: The delegate that will receive order updates.
    /// - Returns: The OrderPoller
    public func createNewPoller(delegate: OrderPollerDelegate) -> OrderPoller{
        return OrderPoller(delegate: delegate)
    }
    //order related variables
    internal var lastOrder : Order?
    
    
    private var a : PaymentMethodInterface? //TO-DO I added this because of a bad access crash. need to find a better way...
    
    //MARK: - Basic Dine-In flow
    
    
    /// The code generated by the MyCheck server is valid for a limited time, for a specific user in a specific location. The server returns a 4 digit code to the recipient. This code, when entered into the POS enables MyCheck to sync the client with his order on the POS and can start receiving order updates and perform actions on it. When Apple Pay is the default payment method, a pending payment Apple Pay token must be created. In order to enable this functionality you MUST set the displayDelegate and ApplePayController parameters
    ///
    ///    - parameter hotelId: The Id of the hotel the venue belongs to. [Optional]
    ///    - parameter restaurantId: The restaurants Id.
    ///    - parameter displayDelegate:A delegate method that will call functions in order to display and remove view controllers. When using Apple Pay the parameter must be set or else an error will be returned. This is because the user must use touch Id in order to approve the future payment.
    ///    - parameter applePayController: Enables the use of Apple Pay. you can equire one from the Wallet singleton. When using Apple Pay the parameter must be set or else an error will be returned.
    ///    - parameter success: A block that is called if the call complete successfully
    ///    - parameter fail: Called when the function fails for any reason
    
    open func generateCode(hotelId: String? , restaurantId: String ,displayDelegate: DisplayViewControllerDelegate? = nil, applePayController:ApplePayController? = nil, success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ) {
        
        guard let applePayController = applePayController ,  let method = applePayController.getApplePayPaymentMethod() else {
            callGenerateCode(hotelId: hotelId, restaurantId: restaurantId, success: success, fail: fail)
            
            return
        }
        a = method
        
        if method.isDefault{
            method.generatePaymentToken(for: nil, displayDelegate: displayDelegate, success: {token in
                self.callGenerateCode(hotelId: hotelId, restaurantId: restaurantId, success: success, fail: fail)
            }, fail: {error in
                if let fail = fail{
                    fail(error)
                }
            })
        }else{
            self.callGenerateCode(hotelId: hotelId, restaurantId: restaurantId, success: success, fail: fail)
            
        }
    }
    
    private func callGenerateCode(hotelId: String? , restaurantId: String , success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ) {
        
        var params : [String: Any] = [  "restaurant_id" :  restaurantId]
        
        if let hotelId = hotelId{
            params ["hotelId"] = hotelId
        }
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.generateCode
            
            return  network.request(urlStr, method: .post, parameters: params , success: { JSON in
                if let code = JSON["code"] as? NSNumber{
                    self.lastOrder = nil
                    success(code.stringValue)
                    
                }else{
                    if let fail = fail{
                        fail(ErrorCodes.badJSON.getError())
                    }
                }
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
    }
    /// Returns the updated order details.
    ///
    ///    - parameter success: A block that is called if the call complete successfully. If the order returne is nil it means their is no open order.
    ///    - parameter fail: Called when the function fails for any reason
    
    public func getOrder( success: ((Order?) -> Void)? , fail: ((NSError) -> Void)? ){
        self.getOrder(order: nil, success: success, fail: fail)
    }
    
    /// Returns the updated order details.
    ///
    ///    - parameter order: The last order received. This is used in order to send the stamp (md5) an thus save the server from regenerating the order if nothing has changed.   [Optional]
    ///    - parameter success: A block that is called if the call complete successfully. If the order returne is nil it means their is no open order.
    ///    - parameter fail: Called when the function fails for any reason
    
    internal func getOrder( order: Order?, success: ((Order?) -> Void)? , fail: ((NSError) -> Void)? ){
        
        var orderId : String? = nil
        var stamp : String? = nil
        
        if let order = order {
            orderId = order.orderId
            stamp = order.stamp
        }
        
        if let lastOrder = lastOrder{//if not first call
            stamp = lastOrder.stamp
            orderId = lastOrder.orderId
        }
        self.callGetOrder(orderId: orderId, stamp: stamp, success: { order in
            self.lastOrder = order
            if let success = success {
                success(order)
            }
        }, fail: { error in
            if error.code == ErrorCodes.noOrderUpdate.rawValue{
                if Session.logDebugData {
                    
                    NotificationCenter.default.post(name:  Notification.Name("MyCheck comunication ouput") , object: "Success callback called")
                }
                if let success = success  {
                    success(self.lastOrder)
                    
                }
                return
            }
            if let fail = fail {
                fail( error)
            }
        })
    }
    
    /// Returns information about the order after the payment
    public struct PaymentResponse{
        ///The new balance after the payment
        public  let newBalance: Double
        /// True iff the order was fully paid
        public  let fullyPaid: Bool
        
    }
  
  
  /// Use this function to understand the payment details before making the payment. Specificly the Tax, subtotal and total amounts that will be paid. This is a obligatory action before payment.
  ///
  ///   - parameter paymentDetails: The details of the payment that should be charged
  ///    - parameter success: A block that is called if the call complete successfully
  ///    - parameter fail: Called when the function fails for any reason
  
  public func generatePaymentRequest(paymentDetails: PaymentDetails,
                                success: @escaping ((PaymentRequest) -> Void) ,
                                fail: @escaping ((NSError) -> Void)){
   
      var params : [String: Any] = [  "orderId" :  paymentDetails.order.orderId]
    if let items = paymentDetails.items{
      
        let itemJSONs = items.map({ $0.createPaymentRequestJSON(amount: 1).flatMap({$0})})
        
        let jsonData = try! JSONSerialization.data(withJSONObject: itemJSONs, options: JSONSerialization.WritingOptions())
        
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        params["items"] =  jsonString
        

    }else{
      
    params["amount"] = paymentDetails.amount.rawValue
    }
    
    
    
    
      guard let domain = Networking.shared.domain else{
        fail(ErrorCodes.notConifgured.getError())
        return
      }
      let urlStr = domain + URIs.generatePaymentRequest
      
      self.network.request(urlStr, method: .get, parameters: params, success: { JSON in
        
        guard let summary = PaymentRequest(paymentDetails: paymentDetails , json: JSON) else{
            fail(ErrorCodes.badJSON.getError())
            
            return
        }
        success(summary)
  
      
    }, fail: fail)
  }
  
    /// Make a payment for an order
    ///
    ///   - parameter paymentDetails: The details of the payment that should be charged
    ///   - parameter paymentMethod: The payment method that should be used in order to charge the user.
    ///    - parameter displayDelegate: A delegate method that will show payment method token creation UI. This must be set only when using Apple Pay.
    ///    - parameter success: A block that is called if the call complete successfully
    ///    - parameter fail: Called when the function fails for any reason
    
    public func makePayment(paymentRequest: PaymentRequest ,paymentMethod: PaymentMethodInterface, displayDelegate: DisplayViewControllerDelegate? = nil,success: @escaping ((PaymentResponse) -> Void) , fail: @escaping ((NSError) -> Void)){
        
        if paymentRequest.isPaid{
            fail(ErrorCodes.paymentRequestAlreadyUsed.getError())
            return
        }
        paymentMethod.generatePaymentToken(for: paymentRequest, displayDelegate: displayDelegate, success: { token in
            let paymentDetails = paymentRequest.paymentDetails
            var params : [String: Any] = [  "orderId" :  paymentRequest.paymentDetails.order.orderId,
                                            "amount": paymentRequest.total,
                                            "tip": paymentDetails.tip,
                                            "ccToken": token]
            
            if let items = paymentDetails.items{
                let itemJSONs = items.map({ $0.createPaymentJSON().flatMap({$0})})
                
                let jsonData = try! JSONSerialization.data(withJSONObject: itemJSONs, options: JSONSerialization.WritingOptions())
                
                let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                params["items"] =  jsonString
                
                
                
            }
            guard let domain = Networking.shared.domain else{
                fail(ErrorCodes.notConifgured.getError())
                return
            }
            let urlStr = domain + URIs.payment
            
            self.network.request(urlStr, method: .post, parameters: params, success: { JSON in
                
                guard let balance = JSON["orderBalance"] as? Double,
                    let fullyPaid = JSON["fullyPaid"] as? Bool else{
                        fail(ErrorCodes.badJSON.getError())
                        
                        return
                }
                    success(PaymentResponse(newBalance: balance, fullyPaid: fullyPaid))
                
            }, fail: fail)
            
        }, fail: fail)
    }
    
    
    /// Place an order to the POS. The items sent will be reordered and served to the user. This will only succeed if their is an open order.
    ///
    ///    - parameter items: An array of tuples where the first parameter is an Int that represents the amount of 'item' to order and the second parameter is the item to reorder.
    ///    - parameter success: A block that is called if the call complete successfully
    ///    - parameter fail: Called when the function fails for any reason
    
    public func reorderItems(items: [(amount: Int , item: Item)] , success: (() -> Void)? , fail: ((NSError) -> Void)? ){
        
        let itemJSONs = items.map({ $0.item.createReorderJSON(amount: $0.amount).flatMap({$0})})
        
        let jsonData = try! JSONSerialization.data(withJSONObject: itemJSONs, options: JSONSerialization.WritingOptions())
        
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        let params : [String: Any] = ["items": jsonString]
        
        
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.reorder
            
            network.request(urlStr, method: .post, parameters: params , success: { JSON in
                if let success = success{
                    success()
                }
                
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
        
    }
    
    
    
    //MARK: - Adding friends to table related functions
    
    /// Get the list of friends that have joint the table. Friends can join by showing a generated 4 digit code to the waiter or to a friend that has already joined the table (using the add friend functions).
    ///
    ///    - parameter success: Returns the list of friends that are in the table
    ///    - parameter fail: Called when the function fails for any reason
    public func getFriendsListAtOpenTable( success: @escaping (([DiningFriend]) -> Void) , fail: ((NSError) -> Void)? ){
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.friendList
            
            return  network.request(urlStr, method: .get, parameters: nil , success: { JSON in
                
                guard let friendsJSON = JSON["users"] as? [[String:Any]] else{
                    if let fail = fail{
                        fail(ErrorCodes.badJSON.getError())
                    }
                    return
                }
                
                let friends = friendsJSON.map { DiningFriend(json: $0) } as! [DiningFriend]
                
                success( friends )
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
        
    }
    
    
    /// Adds a friend to your users currantly open table
    ///
    ///   - parameter friendCode: The 4 digit code the friend recieved from the generate code function
    ///    - parameter success: The friend was added to the table
    ///    - parameter fail: Called when the function fails for any reason
    public func addFriendToOpenTable(friendCode:String, success: (() -> Void)? , fail: ((NSError) -> Void)? ){
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.addFriend
            
            let params : [String: Any] = [  "code" :  friendCode]
            
            return  network.request(urlStr, method: .post, parameters: params , success: { JSON in
                
                if let success = success{
                    success()
                }
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
    }
    
    //MARK: - User past usage information
    
    /// Responds with various statistics about the currant users buying habits using MyCheck.
    ///
    ///    - parameter success: returns statistsics about the currant users buying habits.
    ///    - parameter fail: Called when the function fails for any reason
    public func getUserStatistics( success: ((UserStatistics) -> Void)? , fail: ((NSError) -> Void)? ){
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.stats
            
            
            return  network.request(urlStr, method: .get, parameters: nil , success: { JSON in
                guard let statsJSON = JSON["stats"] as? [String:Any] ,
                    let userStats = UserStatistics(json: statsJSON) else{
                        
                        if let fail = fail{
                            self.broadcastString(string: "Failed paesing stats")

                            fail(ErrorCodes.badJSON.getError())
                        }
                        return
                }
                
                if let success = success{
                    success(userStats)
                }
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
    }
    
    
    /// Responds with a list of all the past payments of the user.
    ///
    ///    - parameter success: A callback with a list of past orders
    ///    - parameter fail: Called when the function fails for any reason
    public func getOrderHistoryList( success: (([OrderHistoryItem]) -> Void)? , fail: ((NSError) -> Void)? ){
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.orderList
            
            
            return  network.request(urlStr, method: .get, parameters: nil , success: { JSON in
                
                guard let ordersJSON = JSON["orders"] as? [[String:Any]]  else{
                    if let fail = fail{
                        fail(ErrorCodes.badJSON.getError())
                    }
                    return
                }
                let orders = ordersJSON.map { OrderHistoryItem(json: $0) } as! [OrderHistoryItem]
                
                if let success = success{
                    success(orders)
                }
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
    }
    
    
    /// Returns the order details of a specific order. . This call is mainly meant for getting past orders.
    ///
    ///    - parameter orderId: The  order Id.
    ///    - parameter success: A block that is called if the call complete successfully. If the order returne is nil it means their is no open order.
    ///    - parameter fail: Called when the function fails for any reason
    
    public func getPastOrder( orderId: String, success: ((Order?) -> Void)? , fail: ((NSError) -> Void)? ){
        
        self.callGetOrder(orderId: orderId, stamp: nil, success: { order in
            if let success = success {
                success(order)
            }
        }, fail: { error in
            
            if let fail = fail {
                fail( error)
            }
        })
    }
    
    //MARK: - Miscellaneous actions
    
    /// Use this function to call a waiter to the table. A 4  digit code must be generated and a table opened in order for this to work. This function is not supported in all venues and must have a POS that supports this functionality.
    ///
    ///    - parameter success: A callback with indicating the request has been dispatched to the POS
    ///    - parameter fail: Called when the function fails for any reason
    public func callWaiter( success: (() -> Void)? , fail: ((NSError) -> Void)? ){
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.callWaiter
            
            
            return  network.request(urlStr, method: .post, parameters: nil , success: { JSON in
                
                if let success = success{
                    success()
                }
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
    }
    
    
    
    /// Sends feedback regarding the last order. The feedback is always for 2 questions, one on a scale of 0-5 and one is free text.
    ///
    ///   - parameter orderId: The order Id the feedback is regarding
    ///   - parameter stars: The number of starts the user gave on a scale of 0-5
    ///   - parameter comment: The text response the user entered.
    ///   - parameter success: The call succeeded
    ///   - parameter fail: The call failed
    public func sendFeedback(for orderId: String,
                             stars:Int,
                             comment:String?,
                             success: (() -> Void)?,
                             fail: ((NSError) -> Void)? ){
        if let domain = Networking.shared.domain {
            let urlStr = domain + URIs.sendFeedback
            
            var params : [String: Any] = [  "stars" :  stars,
                                            "orderId": orderId]
            
            if let comment = comment{
                params ["comments"] = comment
            }
            return  network.request(urlStr, method: .post, parameters: params , success: { JSON in
                
                if let success = success{
                    success()
                }
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
    }
    
    internal func broadcastString(string: String){
        if Session.logDebugData {
            
            NotificationCenter.default.post(name:  Notification.Name("MyCheck comunication ouput") , object: string)
        }
    }
}

//MARK: - general scope functions

internal func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}


