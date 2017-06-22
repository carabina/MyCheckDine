//
//  WalletUIViewCOntrollerViewController.swift
//  MyCheckDine
//
//  Created by elad schiller on 6/20/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MyCheckWalletUI
import MyCheckCore
class WalletUIViewController: UIViewController {
    var checkoutViewController : MCCheckoutViewController?

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var applePaySwitch: UISwitch!
    
    @IBOutlet weak var payPalSwitch: UISwitch!
    
    @IBOutlet weak var masterPassSwitch: UISwitch!
    
    @IBOutlet weak var visaCheckoutSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up switchs to the last setup
        applePaySwitch.setOn(LocalDataa.enabledState(for: .applePay), animated: false)
        masterPassSwitch.setOn(LocalDataa.enabledState(for: .masterPass), animated: false)
        payPalSwitch.setOn(LocalDataa.enabledState(for: .payPal), animated: false)
        visaCheckoutSwitch.setOn(LocalDataa.enabledState(for: .visaCheckout), animated: false)
    }

    override func viewWillAppear(_ animated: Bool){
    super.viewWillAppear(animated)
        containerView.isHidden = !Session.shared.isLoggedIn()

    }
    
    internal override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkout" {
            checkoutViewController = segue.destination as? MCCheckoutViewController
            checkoutViewController?.checkoutDelegate = self
        }
    }
    
    //MARK: - actions
    @IBAction func paymentMethodsPressed(_ sender: AnyObject) {
        let controller = MCPaymentMethodsViewController.createPaymentMethodsViewController(self)
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func payPressed(_ sender: AnyObject) {
        var message = "No payment method available"
        
        //when a payment method is available you can get the method from the checkoutViewController using the selectedMethod variable. If it's nil non exist
        if let method = checkoutViewController!.selectedMethod {
            message =  " " + " token: " + method.token
            UIPasteboard.general.string = method.token
            
        }
        
        
        let alert = UIAlertController(title: "paying with:", message: message, preferredStyle: .alert);
        let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "alert ok but"), style: .default, handler:
        {(alert: UIAlertAction!) in
            
            
        })
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func walletTypeSwitchValueChanged(_ sender: UISwitch) {
       LocalDataa.saveEnableState(for: methodType(for: sender), isEnabled: sender.isOn)
    }
    
    
    
}

extension WalletUIViewController : CheckoutDelegate {
    
    func checkoutViewShouldResizeHeight(_ newHeight : Float , animationDuration: TimeInterval)  -> Void {
        self.heightConstraint.constant = CGFloat(newHeight);
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()//resizing the container
            
        })
    }
    
}

extension WalletUIViewController : MCPaymentMethodsViewControllerDelegate{
    
    
    func dismissedMCPaymentMethodsViewController(_ controller: MCPaymentMethodsViewController){
        controller.dismiss(animated: true, completion: nil)
    }
}

//private helper methods
extension WalletUIViewController{
    fileprivate func methodType(for uiSwitch: UISwitch) -> PaymentMethodType{
        switch uiSwitch {
        case payPalSwitch:
            return .payPal
        case masterPassSwitch:
            return .masterPass
        case applePaySwitch:
            return .applePay
        case visaCheckoutSwitch:
            return .visaCheckout
            
        default:
            return .non
        }
    }
}

