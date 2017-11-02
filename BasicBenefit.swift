//
//  BaseBenefit.swift
//  MyCheckDine
//
//  Created by elad schiller on 11/2/17.
//

import Foundation


public class BasicBenefit {
    
    /// The benefits id
    public let id: String
    
    /// The providers name
    public let provider: String
    
    public init?(JSON: [String: Any]){
        guard let id = JSON["id"] as? String,
            let provider = JSON["provider"] as? String else{
                return nil
        }
        self.id = id
        self.provider = provider
    }
    
}
