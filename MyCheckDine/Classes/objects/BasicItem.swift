

import UIKit
import Gloss

///Represents A single item in an order , or a modifier of an item.
open class BasicItem: NSObject , Decodable {
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
        
        if let paid: Bool = "paid" <~~ json {
            self.paid = paid
        }else{
        self.paid = false
        }
    }
    
  
    
    internal func createPaymentJSON() -> JSON? {
    
        return jsonify([
            "id" ~~> self.Id,
            "amount" ~~> 1.0
            ])
    }
    
    
}

