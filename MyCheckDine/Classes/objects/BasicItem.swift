

import UIKit
import Gloss

///Represents A single item in an order , or a modifier of an item.
open class BasicItem: NSObject , Gloss.Decodable {
    ///The Id of the item.
    open let Id : Int
    ///The name of the item as it was received from the POS.
    open let name : String
    ///The price of the item
    open let price : Double
    ///The amount of the item. At present this will always be 1. If more than 1 item is ordered , multiple Items of the same kind will appear in the bill.
    open let quantity : Int
    ///Was the item paid for.
    open var paid : Bool
    ///The serial Id of the item.
    open let serialId : String?
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
        if quantity > 1{
            print (quantity)
            
        }
        if let paid: Bool = "paid" <~~ json {
            self.paid = paid
        }else{
        self.paid = false
        }
        
        serialId = "serial_id" <~~ json

        if let modifiersJSON: [[String: Any]] = "modifiers" <~~ json{
            let modifiers = modifiersJSON.map({Item(json:$0)}).flatMap({$0})
            self.modifiers = modifiers

        }else{
            self.modifiers = []
        }

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
            "Quantity" ~~> quantity,
            "Modifiers" ~~> modifierJSONs,
            "amount" ~~> self.price.roundedStringForJSON(),
            "Serial_id" ~~> self.serialId,
            "Name" ~~> self.name
            
            ])    }
    
    internal func createPaymentRequestJSON(amount: Int) -> JSON? {
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
            "Price" ~~> self.price.roundedStringForJSON(),
            "Serial_id" ~~> self.serialId,
            "Name" ~~> self.name
            
            ])
    }
    
}

