//
//  File.swift
//  Pods
//
//  Created by elad schiller on 9/17/17.
//
//

import Foundation


enum Result <T>{
    case Success(T)
    case Failure(NSError)
}
