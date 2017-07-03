//
//  DineInViewController.swift
//  MyCheckDine
//
//  Created by elad schiller on 1/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MyCheckDine
import MyCheckWalletUI
import MyCheckCore
class DineInViewController: UITableViewController {
    
    @IBOutlet weak var restaurantIdField: UITextField!
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var itemsSeg: UISegmentedControl!
    @IBOutlet weak var itemsQuantityLabel: UILabel!
    @IBOutlet weak var pollCount: UILabel!
    @IBOutlet weak var pollingSwitch: UISwitch!
    
    var lastOrder : Order? = nil
    let firstSeg = 0
    let lastSeg = 1
    let allSeg = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Dine.shared.poller.delegate = self
        // Do any additional setup after loading the view.
        
        restaurantIdField.text = UserDefaults.standard.string(forKey: "BID")

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pollingSwitch.isOn = Dine.shared.poller.isPolling()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func generateCodePressed(_ sender: Any) {
        if let ID = restaurantIdField.text{
            
            Dine.shared.generateCode(hotelId: nil, restaurantId: ID, displayDelegate: self, applePayController: Wallet.shared.applePayController, success: {
                    code in
                    self.codeLabel.text = code
                    if let BID = self.restaurantIdField.text{
                        UserDefaults.standard.set(BID, forKey: "BID")
                        UserDefaults.standard.synchronize()
                    }
            }, fail: nil)
        
        }
    }
    @IBAction func getOrderPressed(_ sender: UIButton) {
        
        Dine.shared.getOrder(order: nil, success: { order in
            self.lastOrder = order
        }, fail: {error in })
    }
    @IBAction func stepperPressed(_ sender: UIStepper) {
        
        itemsQuantityLabel.text = Int(sender.value).description    }
    @IBAction func reorderPressed(_ sender: Any) {
             if let order = lastOrder ,let qntStr = itemsQuantityLabel.text, let qnt = Int(qntStr), order.items.count > 0{
            var items :[(Int , Item)] = []
            switch itemsSeg.selectedSegmentIndex {
            case firstSeg:
                items.append((qnt ,order.items.first!))
            case lastSeg:
                items.append((qnt ,order.items.last! ))
            case allSeg:
                for item in order.items{
                    items.append((qnt ,item ))
                }
            default:
                break
            }
            Dine.shared.reorderItems(items: items, success: {}, fail: {error in })
            
            
        }else{//no order
            
            let alert = UIAlertController(title: "Error", message: "You must have an order with items before reordering. If the order is open press 'Get order' or turn on the poller", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func pollingSwitched(_ sender: UISwitch) {
        sender.isOn ?
            Dine.shared.poller.startPolling() : Dine.shared.poller.stopPolling()
    }
}

extension DineInViewController : OrderPollerDelegate{
    func orderUpdated(order:Order){
    pollCount.text = "\(Int(pollCount.text!)! + 1)"
        lastOrder = order
    }
    func failingToReceiveUpdates(lastReceivedError: Error , failCount:Int){
    terminal(string: "OrderPollerDelegate fail called", success: false)
    }

}

extension DineInViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension DineInViewController : DisplayViewControllerDelegate{
    func display(viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    func dismiss(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
