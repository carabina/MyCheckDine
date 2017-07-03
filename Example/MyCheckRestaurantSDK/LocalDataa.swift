//
//  LocalDataa.swift
//  MyCheckDine
//
//  Created by elad schiller on 6/20/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import MyCheckWalletUI
import MyCheckCore
struct LocalDataa{

    static func saveEnableState(for type:PaymentMethodType ,isEnabled enabled:Bool ){
        UserDefaults.standard.set(enabled, forKey: type.key())
        UserDefaults.standard.synchronize()
    }
    
    static func enabledState(for type:PaymentMethodType) ->Bool{
       return UserDefaults.standard.bool(forKey: type.key())
        
    }
}

fileprivate extension PaymentMethodType{
    func key() -> String{
        return "\(self.rawValue) payment method type enabled"
    }
}
