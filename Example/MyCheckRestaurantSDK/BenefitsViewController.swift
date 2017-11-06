//
//  BenefitsViewController.swift
//  MyCheckDine_Example
//
//  Created by elad schiller on 11/2/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import MyCheckDine


class BenefitsViewController: UIViewController{
    var benefit : Benefit? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        BIDField.addDoneButtonToKeyboard(target: self, action: #selector(BenefitsViewController.keyboardDoneButtonPressed))
    }
    @IBOutlet weak var BIDField: UITextField!
    
    @IBAction func getBenefitsPressed(_ sender: Any) {
        let BID = BIDField.text!.characters.count > 0 ? BIDField.text : nil
        Benefits.getBenefits(restaurantId: BID, success: { benefitRecieved in
            guard benefitRecieved.count > 0 else{
                TerminalModel.shared.print(string: "Empty benefit list returned")
                return
            }
            self.benefit = benefitRecieved[0]
            
        }, fail: nil)
    }
    
    @IBAction func redeemBenefitPressed(_ sender: Any) {
        guard let benefit = benefit else{
            self.showErrorMessage(message: "No benefits to redeem. call benefit list first and make sure you have benefits to redeem.")
return
        }
        let BID = BIDField.text!.characters.count > 0 ? BIDField.text : nil

        Benefits.redeem(benefit: benefit, restaurantId: BID, success: {
          
          TerminalModel.shared.print(string: "benefit redeemed")
        }, fail: {error in
          TerminalModel.shared.print(string: "fail callback of benefit redeem called (disregard success line above)")

          
        })
    }
    
    func keyboardDoneButtonPressed(){
        
        BIDField.resignFirstResponder()
    }
}

fileprivate extension BenefitsViewController{
     func showErrorMessage(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
