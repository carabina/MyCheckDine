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
class RequestProtocolMock : RequestProtocol{
    let response: RequestProtocolResponse

    init(response: RequestProtocolResponse) {
        self.response = response
    }
    
    
    func request(_ url: String , method: HTTPMethod , parameters: Parameters? , encoding: ParameterEncoding , success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? )  {

        
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
