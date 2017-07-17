//
//  Money.swift
//  Pods
//
//  Created by elad schiller on 6/27/17.
//
//

import Foundation

///Describes an amount of money of a given currency.
public struct Money {
   public let rawValue: Double
    
    internal static var currencyString: String = "$"
    
    init?(value: String) {
        if !value.isNumber{
            return nil
        }
        guard let double = Double(value) else{
            return nil
        }
        rawValue = double
    }
    
    
    
    
   public init(value: Double) {
        rawValue = value
    }
    
   public init(value: Float) {
        rawValue =  Double(value)
    }
    
   public init(value: Int) {
        rawValue =  Double(value)
    }
}


extension Money : Comparable{
    
    public static func ==( lhs: Money , rhs: Money) -> Bool{
        return   lhs.rawValue == rhs.rawValue
    }
    
    public static func <( lhs: Money , rhs: Money) -> Bool{
        return   lhs.rawValue < rhs.rawValue
    }
    
    public static func >( lhs: Money , rhs: Money) -> Bool{
        return   lhs.rawValue > rhs.rawValue
    }
    
    public static func <=( lhs: Money , rhs: Money) -> Bool{
        return   lhs.rawValue <= rhs.rawValue
    }
    
    public static func >=( lhs: Money , rhs: Money) -> Bool{
        return  lhs.rawValue >= rhs.rawValue
    }
    
}
//Math operations
extension Money{
    
    static public func +(lhs: Money, rhs: Money) -> Money{
        return Money(value: lhs.rawValue + rhs.rawValue)
    }
    
    static public func -(lhs: Money, rhs: Money) -> Money{
        return Money(value: lhs.rawValue - rhs.rawValue)
    }
    
    static public func *(lhs: Money, rhs: Money) -> Money{
        return Money(value: lhs.rawValue * rhs.rawValue)

    }
    
    static public func /(lhs: Money, rhs: Money) -> Money{
        return Money(value: lhs.rawValue / rhs.rawValue)
    }
    
   }

extension Money : CustomStringConvertible{
    public var description: String { get{
        return Money.currencyString + String(format: "%\(2)f", rawValue)
        }}
}
