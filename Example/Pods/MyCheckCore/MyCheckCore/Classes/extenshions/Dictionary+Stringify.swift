//
//  File.swift
//  Pods
//
//  Created by elad schiller on 8/8/17.
//
//

import Foundation
extension Dictionary where Key == String{
   public func stringify() -> String?{
        
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            
            return theJSONText
        }
        return nil
        
        
    }
}
