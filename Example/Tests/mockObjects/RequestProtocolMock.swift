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
        encoding: ParameterEncoding = URLEncoding.default,
        addedHeaders: HTTPHeaders? = nil) {
      
        self.url = url
        self.method = method
        self.parameters = parameters
      self.encoding = encoding
      self.addedHeaders = addedHeaders
    }
  
  public static func ==(lhs: RequestParameters, rhs: RequestParameters) -> Bool{
    if let lhsParams = lhs.parameters , rhsParams = rhs.parameters{
      return lhs.url == rhs.url &&
        lhs.method == rhs.method &&
      lhsParams == rhsParams

    }
   
  }
  }
class RequestProtocolMock : RequestProtocol{
    let response: RequestProtocolResponse

    
    var success :  (( _ object: [String: Any]  ) -> Void)?
    
    var fail: ((NSError) -> Void)?
    
    let respondImmediately: Bool
    
    /// Creates a mock object
    ///
    /// - Parameters:
    ///   - response: The response the mock will return.
    ///   - respondImmediately: If true the response will be called as the request is made. Otherwise it will be called when someone calls the response() function
    init(response: RequestProtocolResponse , respondImmediately: Bool = true , requestCheckCallback: ((RequestParameters) -> Void)? = nil ) {
        self.response = response
        self.respondImmediately = respondImmediately
    }
    
    
    func request(_ url: String , method: HTTPMethod , parameters: Parameters? , encoding: ParameterEncoding ,addedHeaders: HTTPHeaders? , success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? )  {

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
