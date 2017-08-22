//
//  ConfigureViewController.swift
//  MyCheckDine
//
//  Created by elad schiller on 1/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MyCheckCore
import MyCheckDine
import MyCheckWalletUI
class ConfigureViewController: UIViewController {
    
    @IBOutlet weak var publishableKeyField: UITextField!
    
    @IBOutlet weak var environmentSegControl: UISegmentedControl!
    
    
    @IBOutlet weak var applePaySwitch: UISwitch!
    
    @IBOutlet weak var payPalSwitch: UISwitch!
    
    @IBOutlet weak var masterPassSwitch: UISwitch!
    
    @IBOutlet weak var visaCheckoutSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishableKeyField.text = UserDefaults.standard.string(forKey: "publishableKey")
        
        // Setting up switchs to the last setup
        applePaySwitch.setOn(LocalDataa.enabledState(for: .applePay), animated: false)
        masterPassSwitch.setOn(LocalDataa.enabledState(for: .masterPass), animated: false)
        payPalSwitch.setOn(LocalDataa.enabledState(for: .payPal), animated: false)
        visaCheckoutSwitch.setOn(LocalDataa.enabledState(for: .visaCheckout), animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func configurePressed(_ sender: Any) {
        UserDefaults.standard.set(publishableKeyField.text, forKey: "publishableKey")
        UserDefaults.standard.synchronize()
        var environment : Environment = Environment.test
        
        
        switch environmentSegControl.selectedSegmentIndex {
        case 0:
            environment = Environment.test
        case 1:
            environment = Environment.sandbox
        default:
            environment = Environment.production
        }
        if let key = publishableKeyField.text{
            
            //This code should normaly be after launch in the application delegate.
            Session.shared.configure(key , environment: environment)
            //setting up wallet according to what the user selected.
            if LocalDataa.enabledState(for: .payPal){
                //   PaypalFactory.initiate("com.mycheck.MyCheckDine-Example")
                
            }
            if LocalDataa.enabledState(for: .applePay){
                ApplePayFactory.initiate(merchantIdentifier: "merchant.com.mycheck.sandbox")
            }
            if LocalDataa.enabledState(for: .visaCheckout){
                VisaCheckoutFactory.initiate(apiKey: "4JWGVZFQ5Y5BX08IF76Y215YIsclCvo9gOIbFUmWHDRi449ZM")
            }
            performSegue(withIdentifier: "pushMainApp", sender: nil)
            
        }else{
            let alert = UIAlertController(title: "Error", message: "Please enter publishable key to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func walletTypeSwitchValueChanged(_ sender: UISwitch) {
        LocalDataa.saveEnableState(for: methodType(for: sender), isEnabled: sender.isOn)
    }
}

//private helper methods
extension ConfigureViewController {
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

extension ConfigureViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

