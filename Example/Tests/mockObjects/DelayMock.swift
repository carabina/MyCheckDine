//
//  DelayMock.swift
//  MyCheckDine
//
//  Created by elad schiller on 7/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
@testable import MyCheckDine

//calls the delay function in order to allow mocking the response from the network
struct DelayMock: DelayInterface{
    var delayCalled: (Double) ->()
    
    init(callback: @escaping (Double) ->() ) {
        delayCalled = callback
    }
    static func delay(_ delay:Double, closure:@escaping ()->()){
        delayCalled(delay)
        closure()
        
    }
}
