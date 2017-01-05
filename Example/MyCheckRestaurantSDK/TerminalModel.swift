//
//  TerminalModel.swift
//  MyCheckRestaurantSDK
//
//  Created by elad schiller on 1/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

protocol TerminalDelegate {
    func terminalOutputUpdated(output: String)
}

class TerminalModel {

    static let shared = TerminalModel()
    var delegate: TerminalDelegate?
    var terminalString = ""
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(TerminalModel.receivedNotification(notification:)), name: Notification.Name("MyCheck comunication ouput"), object: nil)
    }
    func clearTerminal(){
    terminalString = ""
    }
    
     func print(string: String){
    terminalString += string + "\n\n"
        if let delegate = delegate{
            delegate.terminalOutputUpdated(output: terminalString)
        }
    }
    
    @objc func receivedNotification(notification: Notification){
        if let string = notification.object as? String{
            print(string:string)
           
        }
    
    }
}


func terminal(string: String , success: Bool? = nil){
    if let success = success{
    TerminalModel.shared.print( string: success ? "SUCCESS: " : "FAIL: " + string)
    }else{
        TerminalModel.shared.print(string:string)

    }
    
}

