//
//  UserStatistics.swift
//  Pods
//
//  Created by elad schiller on 8/20/17.
//
//

import Foundation
import Gloss

/// Various statistics about the users usage behaviour, that might interest him/her to see
public struct UserStatistics{
    
    /// Number of orders ever made by user using MyCheck
    let orderCount: Int
    
    /// Average amount paid at a table by the currant user.
    let averagePaidTotal: Float
    
    /// Average tip paid by the user
    let averagePaidTip: Float
    
    /// Average time the user is at the table i.e. from the moment the order is opened with the 4 digit code to when the table is closed.
    let averageTimeAtTable: Float
    
    /// Number of rewards the user has at the moment.
    let rewardsCount: Int
    
    /// The name of the location the user dines at the most.
    let favoritePlaceName: String?
    
    /// The number of times the user dined at his / her favorit location
    let favoritePlaceVisitsCount: Int
    
    /// The name of the item the user ordered the most
    let favoriteItemName: String?
    
    /// The total amount the user ever ordered of his / her favorit item.
    let FavoriteItemPurchesCount: Int
    
    
    internal  init?(json: JSON){
        guard let orderCount: Int = "orders" <~~ json else{
            return nil
        }
        self.orderCount = orderCount
        
        guard let averagePaidTotal: Float = "avgPay" <~~ json else{
            return nil
        }
        self.averagePaidTotal = averagePaidTotal
        
        guard let averagePaidTip: Float = "avgTip" <~~ json else{
            return nil
        }
        self.averagePaidTip = averagePaidTip
        
        guard let averageTimeAtTable: Float = "avgTime" <~~ json else{
            return nil
        }
        self.averageTimeAtTable = averageTimeAtTable
        
        guard let rewardsCount: Int = "rewards" <~~ json else{
            return nil
        }
        self.rewardsCount = rewardsCount
        
     
        self.favoritePlaceName = "favPlace" <~~ json
        
        guard let favoritePlaceVisitsCount: Int = "favPlaceVisits" <~~ json else{
            return nil
        }
        self.favoritePlaceVisitsCount = favoritePlaceVisitsCount
        
         favoriteItemName = "favItem"  <~~ json 
        
        guard let FavoriteItemPurchesCount: Int = "favItemBought" <~~ json else{
            return nil
        }
        self.FavoriteItemPurchesCount = FavoriteItemPurchesCount
    }

}
