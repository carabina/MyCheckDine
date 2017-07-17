//
//  File.swift
//  Pods
//
//  Created by elad schiller on 7/6/17.
//
//

import Foundation

internal protocol DelayInterface {
      func delay(_ delay:Double, closure:@escaping ()->())
}


internal struct Delay : DelayInterface{
     func delay(_ delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }


}
