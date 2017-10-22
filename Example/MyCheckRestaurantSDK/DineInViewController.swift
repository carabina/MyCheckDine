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
    @IBOutlet  var amountStack: UIStackView!
    @IBOutlet weak var amountStackheight: NSLayoutConstraint!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var tipField: UITextField!
    @IBOutlet  var selectItemsStack: UIStackView!
    @IBOutlet weak var selectItemStackHeight: NSLayoutConstraint!
    
    @IBOutlet weak var payTypeSeg: UISegmentedControl!
    @IBOutlet weak var selectItemSeg: UISegmentedControl!
    
    @IBOutlet weak var friendCodeField: UITextField!
    
    //feedback related
    @IBOutlet weak var feedbackStepper: UIStepper!
    @IBOutlet weak var feedbackField: UITextField!
    @IBOutlet weak var feedbackStarsLabel: UILabel!
    
    
    var lastOrder : Order? = nil
    let firstSeg = 0
    let lastSeg = 1
    let allSeg = 2
    
    
    let byAmountSeg = 0
    let byItemsSeg = 1
  var poller : OrderPoller?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      poller = Dine.shared.createNewPoller(delegate: self)
      
        //setting default values
        restaurantIdField.text = UserDefaults.standard.string(forKey: "BID")
        
        amountStack.isHidden = false
        selectItemsStack.isHidden = true
        restaurantIdField.addDoneButtonToKeyboard(target:self, action: #selector(self.doneOnKeyboardPressed))
        friendCodeField.addDoneButtonToKeyboard(target:self, action: #selector(self.doneOnKeyboardPressed))

        amountField.addDoneButtonToKeyboard(target:self, action: #selector(self.doneOnKeyboardPressed))
        tipField.addDoneButtonToKeyboard(target:self, action: #selector(self.doneOnKeyboardPressed))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pollingSwitch.isOn = poller!.isPolling()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    @IBAction func generateCodePressed(_ sender: Any) {
        if let ID = restaurantIdField.text{
            
            Dine.shared.generateCode(hotelId: nil, restaurantId: ID, displayDelegate: self, applePayController: Wallet.shared.applePayController, success: {
                code in
                self.codeLabel.text = code
                if let BID = self.restaurantIdField.text{
                    UserDefaults.standard.set(BID, forKey: "BID")
                    UserDefaults.standard.synchronize()
                }
            }, fail: {error in
                TerminalModel.shared.print(string:"app printing: Fail callback called with error: \(error.localizedDescription)")
            })
            
        }
    }
    @IBAction func getOrderPressed(_ sender: UIButton) {
        
        Dine.shared.getOrder(success: { order in
            self.lastOrder = order
        }, fail: {error in
            TerminalModel.shared.print(string:"app printing: Fail callback called with error: \(error.localizedDescription)")
        })
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
            Dine.shared.reorderItems(items: items, success: {}, fail: {error in
                TerminalModel.shared.print(string:"app printing: Fail callback called with error: \(error.localizedDescription)")
            })
            
            
        }else{//no order
            
            showErrorMessage(message: "You must have an order with items before reordering. If the order is open press 'Get order' or turn on the poller")
        }
    }
    
    @IBAction func pollingSwitched(_ sender: UISwitch) {
        sender.isOn ?
           poller?.startPolling() : poller?.stopPolling()
    }
    @IBAction func payPressed(_ sender: Any) {
        //getting payment method
        Wallet.shared.getDefaultPaymentMehthod(success: {method in
            
            guard let order = self.lastOrder else{
                self.showErrorMessage(message: "No order")
                return
            }
            
            guard  (self.tipField.text?.characters.count)! > 0 else{
                self.showErrorMessage(message: "please enter tip")
                return
            }
            
            if self.payTypeSeg.selectedSegmentIndex == self.byAmountSeg {
                
                self.payByAmount(order: order, paymentMethod: method )
                
            }else{//by items
                
                self.payByItem(order: order, paymentMethod: method)
            }
            
        }, fail: {
            error in
            
            self.showErrorMessage(message: error.localizedDescription)
        })
        
    }
    
    
    private func payByAmount(order: Order , paymentMethod: PaymentMethodInterface){
        
        guard  (self.amountField.text?.characters.count)! > 0 else{
            self.showErrorMessage(message: "please enter amount")
            return
        }
        
        
        if let details = PaymentDetails(order: order, amount: Double(self.amountField.text!), tip: Double(self.tipField.text!), paymentMethod: paymentMethod){
            
            Dine.shared.makePayment(paymentDetails: details, displayDelegate: self, success: {_ in 
                
            }, fail: {error in
                
            })
        }else{
            self.showErrorMessage(message: "Invalid payment request (invalid amount or closed order)")
            
        }
        
    }
    
    @objc private func doneOnKeyboardPressed()
    {
        self.tipField.resignFirstResponder()
        self.amountField.resignFirstResponder()
        self.restaurantIdField.resignFirstResponder()
        self.friendCodeField.resignFirstResponder()
    }
    private func payByItem(order: Order , paymentMethod: PaymentMethodInterface){
        guard order.items.count > 0 else{
            self.showErrorMessage(message: "No items in order")
            
            return
        }
        let items: [Item] = {
            
            switch self.selectItemSeg.selectedSegmentIndex{
            case self.firstSeg:
                return [order.items.first!]
            case self.lastSeg:
                return [order.items.last!]
                
            case self.allSeg:
                return order.items
            default:
                return []
            }
        }()
        if let details = PaymentDetails(order: order, items: items, tip: Double(self.tipField.text!), paymentMethod: paymentMethod){
            
            Dine.shared.makePayment(paymentDetails: details, displayDelegate: self, success: {_ in 
                
            }, fail: {error in
                
            })
        }else{
            self.showErrorMessage(message: "Invalid payment request (invalid amount or closed order)")
            
        }
        
    }
    @IBAction func payBySelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case byAmountSeg:
            
            amountStack.isHidden = false
            selectItemsStack.isHidden = true
        case byItemsSeg:
            
            amountStack.isHidden = true
            selectItemsStack.isHidden = false
            
            
        default:
            break
        }
    }
    @IBAction func addFriendToTable(_ sender: Any) {
        Dine.shared.addFriendToOpenTable(friendCode: friendCodeField.text!, success: {
        
        }, fail: {_ in })
    }
    
    @IBAction func getFriendsAtTable(_ sender: Any) {
        
        Dine.shared.getFriendsListAtOpenTable(success: {friends in
        }, fail: {error in
        })
    }
    
    
    @IBAction func getPastOrders(_ sender: Any) {
        Dine.shared.getOrderHistoryList(success: {orders in
        
        }, fail: {error in })
        
        
    }
    
    
    @IBAction func callWaiter(_ sender: Any) {
        Dine.shared.callWaiter(success: nil, fail: {error in })
    }
    
    @IBAction func feedbackStepperPressed(_ sender: Any) {
        feedbackStarsLabel.text = "\(feedbackStepper.value)"
    }

    
    @IBAction func sendFeedback(_ sender: Any) {
        if let orderId = self.lastOrder?.orderId{
        Dine.shared.sendFeedback(for: orderId, stars: Int( feedbackStepper.value), comment: feedbackField.text, success: {
        
        }, fail: {error in
        
        })
        }else{
    showErrorMessage(message: "No open Order")
        }
    }
    private func showErrorMessage(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func getUserStats(_ sender: Any) {
        
        Dine.shared.getUserStatistics(success: {stats in
        
        }, fail: {_ in })
    }
}

extension DineInViewController : OrderPollerDelegate{
    func orderUpdated(order:Order?){
        pollCount.text = "\(Int(pollCount.text!)! + 1)"
        lastOrder = order
    }
    func failingToReceiveUpdates(lastReceivedError: NSError , failCount:Int){
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
