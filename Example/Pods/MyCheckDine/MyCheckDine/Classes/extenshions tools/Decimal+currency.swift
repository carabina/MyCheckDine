//
//  Decimal+currency.swift
//  MyCheckDine
//
//  Created by elad schiller on 11/21/17.
//

import Foundation

fileprivate let currencyBehavior = NSDecimalNumberHandler(roundingMode: .bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)

extension Decimal {
    var roundedCurrency: Decimal {
        return (self as NSDecimalNumber).rounding(accordingToBehavior: currencyBehavior) as Decimal
    }
}
