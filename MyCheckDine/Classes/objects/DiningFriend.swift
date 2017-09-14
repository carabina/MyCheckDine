//
//  DiningFriend.swift
//  Pods
//
//  Created by elad schiller on 8/20/17.
//
//

import Foundation
import Gloss


public struct DiningFriend{
    
    
   /// The ID of the user as he is reprisented in the MyCHeck server.
   public let ID: String
   /// Friends first name
   public let firstName: String
   /// Friends Sirname
   public let lastName: String
   /// Friends email
   public let email: String
    /// The 4 digit code the user recieved in order to open/join the table
    public let clientCode: String
    
    internal  init?(json: JSON){
        guard let ID: String = "id" <~~ json else{
            return nil
        }
        self.ID = ID
        
        guard let firstName: String = "firstName" <~~ json else{
            return nil
        }
        self.firstName = firstName
        
        guard let lastName: String = "lastName" <~~ json else{
            return nil
        }
        self.lastName = lastName
        
        guard let email: String = "email" <~~ json else{
            return nil
        }
      
        self.email = email
        
        guard let clientCode: String = "clientCode" <~~ json else{
            return nil
        }
        self.clientCode = clientCode

    }
    
}
