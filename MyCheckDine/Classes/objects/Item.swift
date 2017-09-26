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
open class Item: Decodable {
  ///The Id of the item.
  open let Id : Int
  ///The name of the item as it was received from the POS.
 open let name : String
  ///The price of the item
 open let price : Double
  ///The amount of the item. At present this will always be 1. If more than 1 item is ordered , multiple Items of the same kind will appear in the bill.
 open let quantity : Int
  ///Was the item paid for.
 open let paid : Bool
  ///The serial Id of the item.
 open let serialId : String?
  ///Is this item allowed to be reorders.
 open let validForReorder :Bool
  ///Should this item be displayed in the reorder list.
 open let showInReorder : Bool
  ///modifiers of the item. This can be a list of toppings or any other kind of complementary item.
 open let modifiers : [Item]
  
    
    //The constructor is for internal use only. Items should be obtained from an Order objects items array or from the modifiers array in the Items object.
    public required init?(json: JSON) {

    guard let Id: Int = "id" <~~ json else{
      return nil
    }
    self.Id = Id
    
    guard let name: String = "name" <~~ json else{
      return nil
    }
    self.name = name
    
    guard let price: Double = "price" <~~ json else{
      return nil
    }
    self.price = price
    
    guard let quantity: Int = "quantity" <~~ json else{
      return nil
    }
    self.quantity = quantity
    
    guard let paid: Bool = "paid" <~~ json else{
      return nil
    }
    self.paid = paid
    
    serialId = "serial_id" <~~ json

    
    self.validForReorder =  "valid_for_reorder" <~~ json ?? true
    
    
   
    self.showInReorder = "show_in_reorder" <~~ json ?? true
    
    guard let modifiers: [Item] = "modifiers" <~~ json else{
      return nil
    }
    self.modifiers = modifiers
    
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
      "Quantity" ~~> amount,
      "Modifiers" ~~> modifierJSONs,
      "Price" ~~> self.price,
      "Serial_id" ~~> self.serialId,
      "Name" ~~> self.name

      ])
  }
    
    internal func createPaymentJSON() -> JSON? {
        //creating modifiers json
        var modifierJSONs :[JSON] = []
        for modifier in modifiers{
            if let json = modifier.createReorderJSON(amount:1){
                modifierJSONs.append(json)
            }
        }
        return jsonify([
            "id" ~~> self.Id,
            "amount" ~~> 1.0
            ])
    }

  
}

