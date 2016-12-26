import Foundation

///The diffrant enviormants you can work with. Used when configuring the SDK and determined the server to query.
public enum Environment {
    /// Production enviormant.
    case Production
    /// Sandbox environment. mimics the behaviour of the production environment but allows the use of test payment methods and user accounts.
    case Sandbox
    /// The latest version of the Server code. The code will work with sandbox and test payment methods like the sandbox environment. It might have new untested and unstable code. Should not be used without consulting with a member of the MyCheck team first!
    case Test
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
    
    
    //the publishable key that reprisents the app using the SDK
    fileprivate var publishableKey: String?

    ///This property points to the singlton object. It should be used for calling all the functions in the class.
    open static let shared = MyCheck()
    
    
    //the enviorment configured
    internal var environment : Environment?
    
    internal var network : Networking?
    
    
    
    ///Sets up the SDK to work on the desired environment with the prefrences specified for the publishable key passed.
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
    ///   - parameter success: A block that is called if the user is logged in succesfully
    ///   - parameter fail: Called when the function fails for any reason
    open func login( _ refreshToken: String  , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ) {
        guard let network = network else {
            let error = NSError(
                domain: Const.clientErrorDomain,
                code: ErrorCodes.MissingPublishableKey,
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
    
    open func generateCode(hotelId: String? , restaurantId: String ,  success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ) {
    
        network?.generateCode(hotelId: hotelId, restaurantId: restaurantId, success: success, fail: fail)
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

}


//MARK: - general scope functions

internal func printIfDebug(_ items: Any...){
    if MyCheck.logDebugData {
        print (items )
    }
}
