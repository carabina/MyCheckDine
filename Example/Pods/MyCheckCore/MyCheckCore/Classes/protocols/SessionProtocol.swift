//
//  SessionProtocol.swift
//  Pods
//
//  Created by elad schiller on 6/11/17.
//
//

import UIKit


///The different enviormants you can configure the SDK to work against.
public enum Environment : String{
    /// Production environment.
    case production = "production"
    /// Sandbox environment. Mimics the behavior of the production environment but allows the use of test payment methods and user accounts.
    case sandbox = "sandbox"
    /// The latest version of the Server code. The code will work with sandbox and test payment methods like the sandbox environment. It might have new untested and unstable code. Should not be used without consulting with a member of the MyCheck team first!
    case test = "test"
}


protocol SessionProtocol {
    ///Sets up the SDK to work on the desired environment with the preferences specified for the publishable key passed.
    ///
    ///   - parameter publishableKey: The publishable key created for your app.
    ///   - parameter environment: The environment you want to work with (production , sandbox or test).
    func configure(_ publishableKey: String , environment: Environment );
    
    
    /// Login a user and get an access_token that can be used for getting and setting data on the user.
    ///
    ///   - parameter refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
    ///   - parameter publishableKey: The publishable key used for the refresh token
    ///   - parameter success: A block that is called if the user is logged in successfully
    ///   - parameter fail: Called when the function fails for any reason
    func login( _ refreshToken: String  , success: @escaping (() -> Void) , fail: ((NSError) -> Void)? );
}
