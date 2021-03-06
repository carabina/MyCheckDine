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
    
    @IBOutlet weak var localeField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
       // containerView.isHidden = !Session.shared.isLoggedIn()
        
        if let locale = Wallet.shared.locale{
            self.localeField.text = locale.localeIdentifier
        }
    }
    
    internal override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkout" {
            checkoutViewController = segue.destination as? MCCheckoutViewController
            checkoutViewController?.checkoutDelegate = self
        }
    }
    
    //MARK: - actions
    @IBAction func paymentMethodsPressed(_ sender: AnyObject) {
        guard let controller = MCPaymentMethodsViewController.createPaymentMethodsViewController(self) else{
            let alert = UIAlertController(title: "Error", message: "You must login in order to display the MCPaymentMethodsViewControllera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func payPressed(_ sender: AnyObject) {
        var message = "No payment method available"
        
        //when a payment method is available you can get the method from the checkoutViewController using the selectedMethod variable. If it's nil non exist
        if let method = checkoutViewController!.selectedMethod {
            method.generatePaymentToken(for: nil, displayDelegate: self, success: {token in
                message =  " " + " token: " + token
                UIPasteboard.general.string = token
                
                
                let alert = UIAlertController(title: "paying with:", message: message, preferredStyle: .alert);
                let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "alert ok but"), style: .default, handler:
                {(alert: UIAlertAction!) in
                    
                    
                })
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }, fail: {error in
                
                let alert = UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert);
                let defaultAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "alert ok but"), style: .default, handler:
                {(alert: UIAlertAction!) in
                    
                    
                })
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            })
            
            
        }
        
        
        
    }
    
    @IBAction func updateLocalePressed(_ sender: Any) {
        
        
        guard let localeTxt = localeField.text
            else{
                
                let alert = UIAlertController(title: "Error", message: "no locale set yet", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                present(alert, animated: true, completion: nil)
                return
        }
        let locale = NSLocale(localeIdentifier: localeTxt)
        Wallet.shared.setLocale(locale:locale, completion: {resutl in
          
          self.checkoutViewController?.refresh()
        })
    }
    
    
    
    
    
}


extension WalletUIViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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



extension WalletUIViewController: DisplayViewControllerDelegate{
    func display(viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    func dismiss(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    
}
