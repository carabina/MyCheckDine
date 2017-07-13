//
//  Data+JSON.swift
//  Pods
//
//  Created by elad schiller on 6/11/17.
//
//

import Foundation

extension Data {
    internal func convertDataToDictionary() -> [String:AnyObject]? {
        
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            //printIfDebug(error)
        }
        
        return nil
    }
}
