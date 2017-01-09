//
//  Networking.swift
//  Pods
//
//  Created by elad schiller on 12/25/16.
//
//

import UIKit
import Alamofire

//A number of error codes you might encounter
internal enum ErrorCodes {
    ///A non JSON answer received from the server or parsing failed on the JSON passed.
    static let badJSON = 971
    /// The user is not logged in.
    static let notLoggedIn = 972
    ///No action can be made since a publishable key was not supplied.
    static let missingPublishableKey = 976
    ///The SDK was not configured.
    static let notConifgured = 977
    ///The order was not updated.
  static let noOrderUpdate = 304
    ///Access token expired. A new one must be generated using login.
    static let tokenExpired = 121
}



class Networking {
    //the address to be used in order to fetch the data needed in order to configur the SDK
    fileprivate enum CDNAddresses{
        static let test = "https://mywalletcdn-test.mycheckapp.com/configurations/7abb7fcd99ee10bbe2981825a560c4a2/v1/main.json"
        static let sandbox = "https://mywalletcdn-sandbox.mycheckapp.com/configurations/7abb7fcd99ee10bbe2981825a560c4a2/v1/main.json"
        static let prod = "https://mywalletcdn-prod.mycheckapp.com/configurations/7abb7fcd99ee10bbe2981825a560c4a2/v1/main.json"
        
    }
    
    var domain : String? = "https://the-test.mycheckapp.com"
    var PCIDomain: String?
    var environment : Environment
    
    var publishableKey : String
    var refreshToken: String?
    var token : String?
    init( publishableKey: String , environment: Environment){
        self.environment = environment
        self.publishableKey = publishableKey
    }
    /// Login a user and get an access_token that can be used for getting and setting data on the user
    ///
    ///    - parameters:
    ///    - refreshToken: The refresh token acquired from your server (that intern calls the MyCheck server that generates it)
    ///    - publishableKey: The publishable key used for the refresh token
    ///    - success: A block that is called if the user is logged in succesfully
    ///    - fail: Called when the function fails for any reason
    ///
    func login( _ refreshToken: String , success: @escaping ((String) -> Void) , fail: ((NSError) -> Void)? ) -> Alamofire.Request?{
        let params : Parameters = [ "refreshToken": refreshToken , "publishableKey": publishableKey]
        
        
        if let domain = domain {
            let urlStr = domain + "/users/api/v1/login"
            
            return  request(urlStr, method: .get, parameters: params , success: { JSON in
                if let token = JSON["accessToken"] as? String{
                    self.refreshToken = refreshToken
                    self.token = token
                    success(token)
                    
                }else{
                    if let fail = fail{
                        fail(self.badJSONError())
                    }
                }
                
            }, fail: fail)
        }else{
            if let fail = fail{
                fail(self.notConfiguredError())
            }
        }
        return nil
    }
    
    
    
    //MARK: - private functions
  internal  func request(_ url: String , method: HTTPMethod , parameters: Parameters? = nil , success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? , encoding: ParameterEncoding = URLEncoding.default) -> Alamofire.Request? {
//        guard let token = token  else{
//            if let fail = fail {
//                fail(notLoggedInError())
//            }
//            return nil
//        }
        //adding general parameters
        var finalParams : Parameters = ["publishableKey":publishableKey] 

        if var params = parameters{
            if let token = token {
            params["accessToken"] = token
            }
            finalParams.append(other:params)
        }
        
        let request = Alamofire.request( url,method: method , parameters:finalParams , encoding:  encoding)
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
                
//                if let value = response.result.value{
//                    self.broadcastString( string:value as! String )
//                }

                
                switch response.result {
                case .success(let JSON):
                    self.broadcastString(string: "Success callback called")
                    if let success = success {
                        success( JSON as! [String : Any] )
                    }
                    
                    
                    
                case .failure(let error):
                    
                    
                    
                        if let data = response.data {
                            
                            let jsonDic = Networking.convertDataToDictionary(data)
                            
                            if let JSON = jsonDic {
                                
                                let msgKey =  JSON["message"] as? String
                                let code = JSON["code"] as? Int
                                if let code = code , let msgKey = msgKey {
                                    
                                    //expired token handeling (login again)
                                    if let refreshToken = self.refreshToken, code == ErrorCodes.tokenExpired{
                                        self.login(refreshToken, success: {token in
                                        self.request(url, method: method, parameters: finalParams, success: success, fail: fail)
                                            return
                                        }, fail: fail)
                                        
                                    }
                                    let errorWithMessage = NSError(domain: Const.serverErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msgKey])
                                    
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
                                    let errorWithMessage = NSError(domain: Const.serverErrorDomain, code: res.statusCode, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription])
                                    if errorWithMessage.code != ErrorCodes.noOrderUpdate{
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
    if let request = request.request ,  MyCheck.logDebugData {

        if let url = request.url{
   
            
            broadcastString(string: "SENDING: \nURL:\n \(url.absoluteString)")
          if  let body = request.httpBody {
            let bodyStr = NSString(data: body, encoding: String.Encoding.utf8.rawValue)

            printIfDebug("BODY IS: ")
            printIfDebug( bodyStr)
            
            broadcastString(string: "BODY: ")
            broadcastString(string: bodyStr as! String)
          }else{
            broadcastString(string:"NO BODY ")

            }




        }
    }
        return request
    }
    
    
    func badJSONError() -> NSError{
        let locMsg = "bad format"
        let error = NSError(domain: Const.serverErrorDomain, code: ErrorCodes.badJSON, userInfo: [NSLocalizedDescriptionKey : locMsg])
        return error
    }
    
    func notConfiguredError() -> NSError{
        let locMsg = "configure wallet was never called or failed"
        let error = NSError(domain: Const.serverErrorDomain, code: ErrorCodes.notConifgured, userInfo: [NSLocalizedDescriptionKey : locMsg])
        return error
    }
    func notLoggedInError() -> NSError{
        let locMsg = "login in order to use this call"
        let error = NSError(domain: Const.serverErrorDomain, code: ErrorCodes.notLoggedIn, userInfo: [NSLocalizedDescriptionKey : locMsg])
        return error
    }
    fileprivate static func convertDataToDictionary(_ data: Data) -> [String:AnyObject]? {
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            printIfDebug(error)
        }
        
        return nil
    }
    
    func isLoggedIn() -> Bool{
        return token != nil
    }
    private func isConfigured() -> Bool {
        return publishableKey != nil
    }
    func broadcastString(string: String){
        if MyCheck.logDebugData {

    NotificationCenter.default.post(name:  Notification.Name("MyCheck comunication ouput") , object: string)
        }
    }
}
