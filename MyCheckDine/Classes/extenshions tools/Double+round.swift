//
//  Double+round.swift
//  MyCheckDine
//
//  Created by elad schiller on 11/9/17.
//

import Foundation


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
