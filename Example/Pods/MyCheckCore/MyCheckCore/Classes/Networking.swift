//
//  Networking.swift
//  Pods
//
//  Created by elad schiller on 6/11/17.
//
//


import Foundation
import UIKit
import CoreData
import Alamofire

//A number of error codes you might encounter
public enum ErrorCodes : Int {
    ///A non JSON answer received from the server or parsing failed on the JSON passed.
    case badJSON = 971
    /// The user is not logged in.
    case notLoggedIn = 972
    ///No action can be made since a publishable key was not supplied.
    case missingPublishableKey = 976
    ///The SDK was not configured.
    case notConifgured = 977
    ///Access token expired. A new one must be generated using login.
    case tokenExpired = 121
    ///The order was not updated.
    case noOrderUpdate = 304
    ///The order was not updated.
    case applePayFailed = 978
    ///The order was not updated.
    case missingDisplayViewControllerDelegate = 979
    ///The order was not updated.
    case actionCanceledByUser = 980
    ///Visa Checkout parsing error.
    case visaCheckoutParsingFailed = 981
    ///No payment method found.
    case noPaymentMethods = 982
    
    case SDKInternalError = 983
    
    case orderIsOpen = 984
    
    case masterPassFailed = 985


    case missingLocale = 986
    
    case noCachedOrder = 987

    case generatePaymentRequestWasNotCalled = 988
    case paymentRequestAlreadyUsed = 989

    
    ///Table is not open.
    case noOpenTable = 10016
    
    case badRequest = -12
    
    
    
    
    // Returns the apropriate error for the error code. If the error is a server error, the server error description can be passed in the message
    //
    // - Parameter message: The error message. If this is not passed the enum cases' default error message will be used.
    // - Returns: The error
    public  func getError(message: String? = nil)-> NSError{
        let msg = getErrorMessage(message: message)
        let error = NSError(domain: Session.Const.serverErrorDomain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey : msg])
        return error
    }
    
    // Returns the apropriate error message for the error code. If the error is a server error, the server error description can be passed in the message
    //
    // - Parameter message: The error message. If this is not passed the enum cases' default error message will be used.
    // - Returns: The message
    func getErrorMessage(message: String? = nil)-> String{
        if let message = message{
            return message
        }
        switch self {
        case .notConifgured:
            return "Configure wallet was never called or failed"
        case .notLoggedIn:
            return "Login in order to use this call"
        case .badJSON:
            return "Bad response format"
        case .missingPublishableKey:
            return "You must first call the configure function of the Session singlton"
        case .badRequest:
            return "Missing parameters , headers or wrong method in call"
        case .applePayFailed:
            return "something whent wrong during the Apple Pay token creation "
        case .missingDisplayViewControllerDelegate:
            return "When making payments or generating a table code with Apple Pay , the DisplayViewControllerDelegate must be set"
        case .actionCanceledByUser:
            return "User Canceled the currant action."
        case .noOpenTable:
            return "Their is no open table"
        case .visaCheckoutParsingFailed:
            return "Couldn't parse Visa Checkout response"
        case .noPaymentMethods:
            return "No payment methods available"
        case .SDKInternalError:
            return "Something whent wrong"
        case .orderIsOpen:
            return "this action cannot be complete when an order is open"
        case .masterPassFailed:
            return "masterpass failed"
        case .missingLocale:
           return "Missing Locale"
        case .noCachedOrder:
           return "The SDK has no cached Order details. You may try to send a request without the use of cache"
        case .generatePaymentRequestWasNotCalled :
            return "Generate payment request must be called before every payment"
        case .paymentRequestAlreadyUsed:
            return "The request was already charged. please create a new PaymentRequest."
        default:
            return  ""
        }
    }
}

// The suffixes for the various API calls. they will be added to the end of the 'Domain' received from the server in the configure call.
internal struct URIs{
    
    static let login = "/users/api/v1/login"
    
}

// The super class for the public Singletons supplied by MyCheck. It takes care of comunication and some other basics.
public class Networking {
    
    
    //The configuration file as it wasreceived from the server.
    fileprivate var configJSON: [String : Any]?
    //The prefix for the API calls. If this is nil it means the SDK is not configured and no API calls can be made.
    public var domain : String?
    
    fileprivate var PCIDomain: String?
    
    public var environment : Environment?
    
    //The refresh token is used to login the user ether when the called explicitly by the 'login' function or when the last token expires.
    fileprivate var refreshToken: String?
    
    //Identifies the app using the SDK
    internal var publishableKey : String?
    
    //The token that establishes the users session.
    internal var token : String?
    
    
    private var _UUID : String? = nil
    //A UDID to identify that must be passed on every API call in a header.
    fileprivate var UUID : String  {
        get{
            if let UUID = _UUID{
                return UUID
            }
            _UUID  = NSUUID().uuidString
            return _UUID!
        } }
    
    
    public var configureCalled: Bool  {
        get {
            if let _ = environment , let _ = publishableKey{
                return true
            }
            return false
        }
    }
    
    public var configuredComplete: Bool  {
        get {
            if let _ = domain , let _ = configJSON {
                return true
            }
            return false
        }
    }
    
    //used in order to make all the API calls. usualy this is 'self' as you see in the constructor. It is replaced by a mock object for testing.
    internal var network : RequestProtocol?
    
    private static var _shared  :Networking? = Networking()
    
    ///This property points to the singleton object. It should be used for calling all the functions in the class.
    public class var shared: Networking
    {
        if let singleton = _shared
        {
            return singleton
        }
        _shared = Networking()
        return _shared!
    }
    
    //MARK: - public funtions
    
    /// Check if a user is logged in or not
    ///
    ///    - Returns: True if the user is logged in and false otherwise.
    internal func isLoggedIn() -> Bool{
        return token != nil
    }
    
    /// Log the user out of MyCheck.
    internal func logout(){
        token = nil
        refreshToken = nil

        
    }
    
    //MARK: - internal methods
    
    internal init() {
        network = self
    }
    
    
    
    // Login a user and get an access_token that can be used for getting and setting data on the user
    //    - parameters:
    //    - refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
    //    - publishableKey: The publishable key used for the refresh token
    //    - success: A block that is called if the user is logged in succesfully
    //    - fail: Called when the function fails for any reason
    
    internal func callLogin( _ refreshToken: String  , success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ) {
        let params : Parameters = [ "refreshToken": refreshToken ,
                                    "withMetadata": 1]
        
        
        if let domain = domain {
            let urlStr = domain + URIs.login
            
            return  network!.request(urlStr, method: .post, parameters: params , success: { JSON in
                if let token = JSON["accessToken"] as? String{
                    self.refreshToken = refreshToken
                    self.token = token
                    let notificationCenter = NotificationCenter.default
                    notificationCenter.post(name: Notification.Name( Session.Const.loggedInNotification), object: nil)
                    success(token)
                    
                }else{
                    if let fail = fail{
                        fail(ErrorCodes.badJSON.getError())
                    }
                }
                
            }, fail: {error in
                fail!(ErrorCodes.notConifgured.getError())
                
                
            })
        }else{
            if let fail = fail{
                fail(ErrorCodes.notConifgured.getError())
            }
        }
        return
    }
    
    
    //This array will contain all the blocks that are awaiting a response. This complexity is needed since a few SDKs might try to access it at the get go.
    private static var awaitingConfigureResponse :[(((_ JSON: [String: Any]) -> Void)? , ((NSError) -> Void)? )] = []
    
    
    /// If the configure call was never called it will call the server. if the answer was cached it will return the cached answer.
    ///
    /// - Parameters:
    ///   - publishableKey: The publishableKey reprisenting the clients app. Must be past on the first call.
    ///   - environment: The environment that should be used. Must be past on the first call.
    ///   - success: Called when the function succeeded
    ///   - fail: Called whent the function fails
    public func configure(_ publishableKey: String? = nil, environment: Environment? = nil, success: ((_ JSON: [String:Any]) -> Void)? , fail:((_ error: NSError) -> Void)?){
        
        if let environment = environment , let publishableKey = publishableKey{
            self.environment = environment
            self.publishableKey = publishableKey
        }
        
        URLCache.shared .removeAllCachedResponses()
        
        //SDK user must call config and set the environment and publishable key
        guard let environment = self.environment , let _ = self.publishableKey else {
            if let fail = fail{
                fail(ErrorCodes.missingPublishableKey.getError())
            }
            return
        }
        
        if let configJSON = configJSON{
            if let success = success{
                success(configJSON)
            }
            return
        }
        
        let urlStr = environment.getCDNAddresses()
        Networking.awaitingConfigureResponse.append((success, fail))
        
        //If the array was not empty it means a call was already made and we do not need to make a second
        if  Networking.awaitingConfigureResponse.count > 1{
            return
        }

        let params = ["publishable_key": self.publishableKey!,
                      "public_only":1] as [String : Any]
        network!.request(urlStr, method: .get, parameters: params , success: { JSON in
            
            guard  let config1: [String:Any] = JSON["config"] as? [String : Any],
                let config2: [String:Any] = config1["Config"] as? [String : Any],
                let coreJSON: [String:Any] = config2["core"] as? [String : Any] else{
                
                for (_ , failed) in Networking.awaitingConfigureResponse{//TO-DO abstract the calling of the functions
                    if let failed = failed{
                        failed(ErrorCodes.badJSON.getError())
                    }
                }
                Networking.awaitingConfigureResponse = []
                return
            }
            self.domain = coreJSON["Domain"] as? String
            
            //If their is no domain the method should fail
            guard let _ = self.domain else{
                for (_ , failed) in Networking.awaitingConfigureResponse{
                    if let failed = failed{
                        failed(ErrorCodes.badJSON.getError())
                    }
                }
                Networking.awaitingConfigureResponse = []
                
                return
            }
            self.configJSON = config2
            //calling all awaiting success blocks
            for (succeeded , _) in Networking.awaitingConfigureResponse{
                if let succeeded = succeeded{
                    succeeded( config2)
                }
            }
            Networking.awaitingConfigureResponse = []
            
            
            
            
        }, fail: fail)
        
        
    }
    
    internal func broadcastString(string: String){
        if Session.logDebugData {
            
            NotificationCenter.default.post(name:  Notification.Name("MyCheck comunication ouput") , object: string)
        }
    }
    
    
    /// Used for all server calls. calls the URL, adds the default headers and values, and responds to some of the errors.
    ///
    /// - Parameters:
    ///   - url: The URL to call
    ///   - method: The HTTP method
    ///   - parameters: The parameters that should be sent a
    ///   - encoding: the body encodibg (default key value, JSON etc)
    ///   - success: Called when the function succeeded
    ///   - fail: Called whent the function fails
    public  func request(_ url: String , method: HTTPMethod , parameters: Parameters? = nil , encoding: ParameterEncoding = URLEncoding.default ,addedHeaders: HTTPHeaders? = nil, success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? )  {
        
        //adding general parameters
        var finalParams : Parameters = [:]
        if let parameters = parameters{
            finalParams = parameters
        }
        finalParams["publishableKey"] = publishableKey
        
        if let token = token {
            finalParams["accessToken"] = token
        }
        
        
        
        var headers: HTTPHeaders = [
            "X-Uuid": UUID,
            "device": UIDevice.current.name,
            "OSVersion":UIDevice.current.systemVersion
        ]
        
        if let addedHeaders = addedHeaders{
            
            headers.append(other: addedHeaders)
            
        }
        
        
        let request = Alamofire.request( url,method: method , parameters:finalParams , encoding:  encoding , headers: headers)
            .validate(statusCode: 200..<201)
            .validate(contentType: ["application/json"])
            .responseString{ response in
                
                if let data = response.data {
                    if let json = String(data: data, encoding: String.Encoding.utf8){
                        if let response = response.response{
                            self.broadcastString(string:"STATUS: \(response.statusCode)" )
                        }
                        self.broadcastString(string:"RESPONSE: \n" + json)                }
                }
            }.responseJSON { response in
                
                
                switch response.result {
                case .success(let JSON):
                    self.broadcastString(string: "Success callback called")
                    if let success = success {
                        success( JSON as! [String : Any] )
                    }
                    
                    
                    
                case .failure(let error):
                    
                    
                    
                    if let data = response.data {
                        
                        let jsonDic = data.convertDataToDictionary()
                        
                        if let JSON = jsonDic {
                            
                            let msgKey =  JSON["message"] as? String
                            let code = JSON["code"] as? Int
                            if let code = code , let msgKey = msgKey {
                                
                                //expired token handeling (login again)
                                if let refreshToken = self.refreshToken, code == ErrorCodes.tokenExpired.rawValue{
                                    self.token = nil
                                    self.callLogin(refreshToken, success: {token in
                                        self.request(url, method: method, parameters: finalParams, success: success, fail: fail)
                                        return
                                    }, fail: fail)
                                    
                                return
                                }
                                let errorWithMessage = NSError(domain: Session.Const.serverErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msgKey])
                                
                                self.broadcastString(string: "Fail callback called")
                                
                                if let fail = fail {
                                    fail(errorWithMessage)
                                }
                            } else{
                                self.broadcastString(string: "Fail callback called")
                                if let fail = fail {
                                    fail(error as NSError)
                                }                                }
                        }else{
                            if let res = response.response{
                                let errorWithMessage = NSError(domain: Session.Const.serverErrorDomain, code: res.statusCode, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription])
                                if errorWithMessage.code != ErrorCodes.noOrderUpdate.rawValue{
                                    self.broadcastString(string: "Fail callback called")
                                }
                                if let fail = fail {
                                    fail(errorWithMessage)
                                }
                                return
                            }
                            self.broadcastString(string: "Fail callback called")
                            
                            if let fail = fail {
                                fail(error as NSError)
                            }                            }
                        
                    }
                    
                }
        }
        if let request = request.request ,  Session.logDebugData {
            
            if let url = request.url{
                
                
                broadcastString(string: "SENDING: \nURL:\n \(url.absoluteString)")
                if  let body = request.httpBody {
                    let bodyStr = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                    
                    printIfDebug("BODY IS: ")
                    printIfDebug( bodyStr ?? "No body")
                    
                    broadcastString(string: "BODY: ")
                    broadcastString(string: bodyStr! as String)
                }else{
                    broadcastString(string:"NO BODY ")
                    
                }
                
                
                
                
            }
        }
    }
    
    //This is an internal function meant only for unit testing!
    //It will dispose of the singleton an thus triger creation of a new instance next time the shrard property is accessed.
    internal func dispose()
    {
        Networking._shared = nil
        
    }
}
//MARK: - private functions


fileprivate extension Environment{
    
    //the address to be used in order to fetch the data needed in order to configur the SDK.
    func getCDNAddresses() -> String{
        
        let uri = "/users/api/v2/business/configurations"
       
        switch self {
        case .test:
            return "https://the-test.mycheckapp.com" + uri
        case .sandbox:
            return  "https://the-sandbox.mycheckapp.com" + uri
        case .production:
            return  "https://the.mycheckapp.com" + uri
        }
    }
}

extension Networking : RequestProtocol{
}
