//
//  MyCheckSession.swift
//  Pods
//
//  Created by elad schiller on 18/05/2017.
//
//

import UIKit






public class Session : NSObject {
    
    
    public enum Const {
        public static let clientErrorDomain = "MyCheck SDK client error domain"
        public static let serverErrorDomain = "MyCheck server error domain"
        public static let loggedInNotification = "com.mycheck.loggedInNotification"
        public static let loggedOutNotification = "com.mycheck.loggedOutNotification"
        
        
    }
    
    
    private static var _shared  :Session? = Session()
    
    //The object used for making calls to the server and managing the session.
    private let network = Networking.shared
    
    ///This property points to the singleton object. It should be used for calling all the functions in the class.
    public class var shared: Session
    {
        if let singleton = _shared
        {
            return singleton
        }
        _shared = Session()
        return _shared!
    }
    
    
   
    
    ///Sets up the SDK to work on the desired environment with the preferences specified for the publishable key passed.
    ///
    ///   - parameter publishableKey: The publishable key created for your app.
    ///   - parameter environment: The environment you want to work with (production , sandbox or test).
    public func configure(_ publishableKey: String , environment: Environment ){
        network.configure(publishableKey, environment: environment, success: {JSON in
            
            
           
            
        }, fail: nil)
    }
    
    
    
    
    
    
    
    /// Login a user and get an access_token that can be used for getting and setting data on the user.
    ///
    ///   - parameter refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
    ///   - parameter publishableKey: The publishable key used for the refresh token
    ///   - parameter success: A block that is called if the user is logged in successfully
    ///   - parameter fail: Called when the function fails for any reason
    open func login( _ refreshToken: String  , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? ) {
        if !network.configureCalled{
            
            if let fail = fail{
                fail(ErrorCodes.missingPublishableKey.getError())
            }
            return
        }
        
        let loginFunc : () -> Void = {
            
            self.network.callLogin( refreshToken , success: {token in
                success()
                
            }, fail: fail)
            
            
        }
        
        
        if network.configuredComplete {
            
            loginFunc()
            
        }else {//Networking.manager.domain == nil ,in this case config was called but didnt complete
            network.configure( success: { _ in
                loginFunc()
                
            }, fail: fail)
        }
    }
    
    
    /// Check if a user is logged in or not
    ///
    ///    - Returns: True if the user is logged in and false otherwise.
    public func isLoggedIn() -> Bool{
        return network.isLoggedIn()
    }
    
    /// Log the user out of MyCheck.
    public func logout(){
        network.logout()
        let notificationCenter = NotificationCenter.default
        notificationCenter.post(name: Notification.Name( Const.loggedOutNotification), object: nil)

        
    }
    
    
    
    //MARK - debug and test help
    
    //This is an internal function meant only for unit testing!
    //It will dispose of the singleton an thus triger creation of a new instance next time the shrard property is accessed.
    internal func dispose()
    {
        Session._shared = nil
        network.dispose()
        print("Disposed Singleton instance")
    }
    
    
    
    
    ///If set to true the SDK will print to the log otherwise it will not. Note that you must turn this off when shipping the app since sensitive data might be printed to the log if it is turned on!!!
    public static var logDebugData = false
    
    
    
    
    
    
    
    
}


internal func printIfDebug(_ items: Any...){
    if Session.logDebugData {
        print (items )
    }
}

//an empty extenshion added in order to be able to mock this object
extension Session : SessionProtocol{
    
}
