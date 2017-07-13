//
//  File.swift
//  Pods
//
//  Created by elad schiller on 6/12/17.
//
//

import Foundation
import Alamofire

internal protocol RequestProtocol {
    
    func request(_ url: String , method: HTTPMethod , parameters: Parameters? , encoding: ParameterEncoding ,addedHeaders: HTTPHeaders? , success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? )  ;
}

extension RequestProtocol{
    
    func request(_ url: String , method: HTTPMethod , parameters: Parameters? , encoding: ParameterEncoding = URLEncoding.default , addedHeaders: HTTPHeaders? = nil, success: (( _ object: [String: Any]  ) -> Void)? , fail: ((NSError) -> Void)? )  {
    
        return request(url, method: method, parameters: parameters, encoding: encoding, addedHeaders:addedHeaders, success: success, fail: fail)
    }

}
