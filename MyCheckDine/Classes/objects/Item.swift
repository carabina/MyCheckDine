//
//  Item.swift
//  Pods
//
//  Created by elad schiller on 27/12/2016.
//
//

import UIKit
import Gloss

///Represents A single item in an order , or a modifier of an item.
open class Item: BasicItem {

  
  ///Is this item allowed to be reorders.
 open let validForReorder :Bool
  ///Should this item be displayed in the reorder list.
 open let showInReorder : Bool

  
    
    //The constructor is for internal use only. Items should be obtained from an Order objects items array or from the modifiers array in the Items object.
    public required init?(json: JSON) {

        
       

    
    self.validForReorder =  "valid_for_reorder" <~~ json ?? true
    
    
   
    self.showInReorder = "show_in_reorder" <~~ json ?? true
    
    
        super.init(json: json)

  }
  
  internal func createReorderJSON(amount: Int) -> JSON? {
    //creating modifiers json
    var modifierJSONs :[JSON] = []
    for modifier in modifiers{
      if let json = modifier.createReorderJSON(amount:1){
      modifierJSONs.append(json)
      }
    }
    return jsonify([
      "ID" ~~> self.Id,
      "Quantity" ~~> quantity,
      "Modifiers" ~~> modifierJSONs,
      "Price" ~~> self.price,
      "Serial_id" ~~> self.serialId,
      "Name" ~~> self.name

      ])
  }
    
    
}

