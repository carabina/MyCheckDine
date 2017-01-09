import Foundation

///The different enviormants you can configure the SDK to work against.
public enum Environment {
    /// Production environment.
    case production
    /// Sandbox environment. Mimics the behavior of the production environment but allows the use of test payment methods and user accounts.
    case sandbox
    /// The latest version of the Server code. The code will work with sandbox and test payment methods like the sandbox environment. It might have new untested and unstable code. Should not be used without consulting with a member of the MyCheck team first!
    case test
}




internal enum Const {
    static let clientErrorDomain = "MyCheck SDK client error domain"
    static let serverErrorDomain = "MyCheck server error domain"
    
}

///MyCheckWallet is a singleton that will give you access to all of the MyCheck functionality. It has all the calls needed to manage a user's payment methods.
open class MyCheck{
    internal static let refreshPaymentMethodsNotification = "com.mycheck.refreshPaymentMethodsNotification"
    internal static let loggedInNotification = "com.mycheck.loggedInNotification"
    
    
    ///If set to true the SDK will print to the log otherwise it will not
    open static var logDebugData = false
    
    
    //the publishable key that represents the app using the SDK
    fileprivate var publishableKey: String?
    
    ///This property points to the singleton object. It should be used for calling all the functions in the class.
    open static let shared = MyCheck()
    
    ///When activated this object polls the MyCheck server in order to fetch order updates. Call The startPolling function and set the delegate in order to receive updates. You should generally use the poller starting when a 4 digit code is created until the order is closed or canceled.
    open var poller = OrderPoller()
    
    
    //the environment configured
    internal var environment : Environment?
    
    internal var network : Networking?
    
    //order related variables
    internal var lastOrder : Order?
    
    ///Sets up the SDK to work on the desired environment with the preferences specified for the publishable key passed.
    ///
    ///   - parameter publishableKey: The publishable key created for your app.
    ///   - parameter environment: The environment you want to work with (production , sandbox or test).
    open func configure(_ publishableKey: String , environment: Environment ){
        
        self.publishableKey = publishableKey
        self.configure(publishableKey, environment: environment, success: nil, fail: nil)
        self.environment = environment
        network = Networking(publishableKey: publishableKey, environment: environment)
    }
    
    fileprivate func configure(_ publishableKey: String , environment: Environment , success: (() -> Void)? , fail:((_ error: NSError) -> Void)?){
    }
    
    
    
    
    /// Login a user and get an access_token that can be used for getting and setting data on the user.
    ///
    ///   - parameter refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
    ///   - parameter publishableKey: The publishable key used for the refresh token
    ///   - parameter success: A block that is called if the user is logged in successfully
    ///   - parameter fail: Called when the function fails for any reason
    open func login( _ refreshToken: String  , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ) {
        guard let network = network else {
            let error = NSError(
                domain: Const.clientErrorDomain,
                code: ErrorCodes.missingPublishableKey,
                userInfo: [
                    NSLocalizedDescriptionKey: "you must first call the configure function of the MyCheckWallet singlton"]
            )
            if let fail = fail{
                fail(error)
            }
            return
        }
        
        let loginFunc = {
            let request = self.network!.login( refreshToken , success: {token in
                success()
                
            }, fail: fail)
            
            
        }
        
        
        if network.domain != nil {
            
            loginFunc()
            
        }else {//Networking.manager.domain == nil ,in this case config was called but didnt complete
            configure(self.publishableKey!, environment: self.network!.environment, success: {
                loginFunc()
                
            }, fail: fail)
        }
    }
    
    open func logout(){
        if let network = network{
    network.token = nil
        network.refreshToken = nil
        
        }
    }
    
    
    
    
    
    
    
    /// Check if a user is logged in or not
    ///
    ///    - Returns: True if the user is logged in and false otherwise.
    
    open func isLoggedIn() -> Bool {
        guard let  network = network else{
            return false
        }
        return network.isLoggedIn()
        
    }
    
    
    
    /// The code generated by the MyCheck server is valid for a limited time, for a specific user in a specific location. The server returns a 4 digit code to the recipient. This code, when entered into the POS enables MyCheck to sync the client with his order on the POS and can start receiving order updates and perform actions on it.
    ///
    ///    - parameter hotelId: The Id of the hotel the venue belongs to. [Optional]
    ///    - parameter restaurantId: The restaurants Id.
    ///    - parameter success: A block that is called if the call complete successfully
    ///    - parameter fail: Called when the function fails for any reason
    
    open func generateCode(hotelId: String? , restaurantId: String ,  success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ) {
        
        network?.generateCode(hotelId: hotelId, restaurantId: restaurantId, success: { code in
            self.lastOrder = nil //If we had an open order we will want to ditch it at this point.
            success(code)
        }, fail: fail)
    }
    
    
    /// Returns the updated order details.
    ///
    ///    - parameter order: The last order received. This is used in order to send the stamp (md5) an thus save the server from regenerating the order if nothing has changed.   [Optional]
    ///    - parameter success: A block that is called if the call complete successfully
    ///    - parameter fail: Called when the function fails for any reason
    
    open func getOrder( order: Order? , success: ((Order) -> Void)? , fail: ((NSError) -> Void)? ){
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
        network?.getOrder(orderId: orderId, stamp: stamp, success: { order in
            self.lastOrder = order
            if let success = success {
                success(order)
            }
        }, fail: { error in
            if error.code == ErrorCodes.noOrderUpdate{
                if MyCheck.logDebugData {
                    
                    NotificationCenter.default.post(name:  Notification.Name("MyCheck comunication ouput") , object: "Success callback called")
                }
                if let success = success , let order = order {
                    success(order)
                    
                }
                return
            }
            if let fail = fail {
                fail( error)
            }
        })
    }
    
    
    /// Place an order to the POS. The items sent will be reordered and served to the user. This will only succeed if their is an open order.
    ///
    ///    - parameter items: An array of tuples where the first parameter is an Int that represents the amount of 'item' to order and the second parameter is the item to reorder.
    ///    - parameter success: A block that is called if the call complete successfully
    ///    - parameter fail: Called when the function fails for any reason

    open func reorderItems(items: [(amount: Int , item: Item)] , success: (() -> Void)? , fail: ((NSError) -> Void)? ){
        network?.reorderItems(items: items, success: {
            if let success = success{
                success()
            }
        }, fail: fail)
        
    }
}


//MARK: - general scope functions

internal func printIfDebug(_ items: Any...){
    if MyCheck.logDebugData {
        print (items )
    }
}

internal func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

