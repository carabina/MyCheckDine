//
//  String+IsNumber.swift
//  Pods
//
//  Created by elad schiller on 6/27/17.
//
//

import Foundation

public extension String {
    
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }
    
}
