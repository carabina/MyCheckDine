//
//  RequestProtocolMock.swift
//  MyCheckCore
//
//  Created by elad schiller on 6/12/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire
@testable import MyCheckCore
enum RequestProtocolResponse{
    case success([String: Any])
    case fail(NSError)
}


struct RequestParameters {
   let url: String
   let method: HTTPMethod
   let parameters: Parameters?
   let encoding: ParameterEncoding
   let addedHeaders: HTTPHeaders?
    
    init( url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        addedHeaders: HTTPHeaders?) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
        self.addedHeaders = addedHeaders
    }
}
class RequestProtocolMock : RequestProtocol{
    let response: RequestProtocolResponse

    
    var success :  (( _ object: [String: Any]  ) -> Void)?
    
    var fail: ((NSError) -> Void)?
    
    let respondImmediately: Bool
    
    //the callback is called when request is called and passes the parameters to the callback
    let callback: ((RequestParameters) -> Void )?
    /// Creates a mock object
    ///
    /// - Parameters:
    ///   - response: The response the mock will return.
    ///   - respondImmediately: If true the response will be called as the request is made. Otherwise it will be called when someone calls the response() function
    init(response: RequestProtocolResponse , respondImmediately: Bool = true , callback: ((RequestParameters) -> Void )? = nil) {
        self.response = response
        self.respondImmediately = respondImmediately
        self.callback = callback
    }
    
    
    func request(_ url: String , method: HTTPMethod , parameters: Parameters? , encoding: ParameterEncoding ,addedHeaders: HTTPHeaders? , success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? )  {
        
        //let the callback know what was sent
        if let callback = callback{
            let request = RequestParameters(url: url, method: method, parameters: parameters, encoding: encoding, addedHeaders: addedHeaders)
            callback(request)
        }
        
        self.success = success
        self.fail = fail
        if respondImmediately{
        respond()
        }
        
            }
    
    
    /// Calls the apropriat callback
    func respond(){
       
        switch response {
        case .success(let JSON):
            if let success = success {
                success(JSON)
            }
        case .fail(let error):
            if let fail = fail{
                fail(error);
            }
            
        }

    }
    
 
}
