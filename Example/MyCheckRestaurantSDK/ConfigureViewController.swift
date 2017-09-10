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
    
    let savedDatapublishableKeyKey = "publishableKey"
    let savedDataMerchantIdKey = "ApplePayMerchantId"
    
    @IBOutlet weak var publishableKeyField: UITextField!
    
    @IBOutlet weak var environmentSegControl: UISegmentedControl!
    
    @IBOutlet weak var applePaySwitch: UISwitch!
    
    @IBOutlet weak var payPalSwitch: UISwitch!
    
    @IBOutlet weak var masterPassSwitch: UISwitch!
    
    @IBOutlet weak var visaCheckoutSwitch: UISwitch!
    
    @IBOutlet weak var applePayMerchantIdStackView: UIStackView!
    
    @IBOutlet weak var merchantIdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSavedDataTextOnFields()
        // Setting up switchs to the last setup
        applePaySwitch.setOn(LocalDataa.enabledState(for: .applePay), animated: false)
        masterPassSwitch.setOn(LocalDataa.enabledState(for: .masterPass), animated: false)
        payPalSwitch.setOn(LocalDataa.enabledState(for: .payPal), animated: false)
        visaCheckoutSwitch.setOn(LocalDataa.enabledState(for: .visaCheckout), animated: false)
        animateApplePayMerchantIdStackView(shouldShow: applePaySwitch.isOn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func configurePressed(_ sender: Any) {
        getFieldsSavedDataText()
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
        
        guard let key = publishableKeyField.text, key != "" else {
        let alert = UIAlertController(title: "Error", message: "Please enter publishable key to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        //This code should normaly be after launch in the application delegate.
        Session.shared.configure(key , environment: environment)
        //setting up wallet according to what the user selected.
        if LocalDataa.enabledState(for: .payPal){
            //   PaypalFactory.initiate("com.mycheck.MyCheckDine-Example")
            
        }
        if LocalDataa.enabledState(for: .applePay){
            guard let merchantId = merchantIdField.text, merchantId != "" else {
                let alert = UIAlertController(title: "Error", message: "Please enter merchant ID to continue", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
        
           ApplePayFactory.initiate(merchantIdentifier: merchantId)
        }
        if LocalDataa.enabledState(for: .visaCheckout){
            VisaCheckoutFactory.initiate(apiKey: "S8TQIO2ERW9RIHPE82DC13TA9Uv8FdB9Uu7EBRyZHDCNsp7JU")
        }
        performSegue(withIdentifier: "pushMainApp", sender: nil)
        
    }
    
    @IBAction func walletTypeSwitchValueChanged(_ sender: UISwitch) {
        LocalDataa.saveEnableState(for: methodType(for: sender), isEnabled: sender.isOn)
        
    }
    
    func animateApplePayMerchantIdStackView(shouldShow : Bool) {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: UIViewAnimationOptions.transitionCurlDown, animations: {
            if shouldShow {
                self.applePayMerchantIdStackView.isHidden = false
            } else {
                self.applePayMerchantIdStackView.isHidden = true
            }
        }, completion: nil)
    }
    
    func setSavedDataTextOnFields() {
        publishableKeyField.text = UserDefaults.standard.string(forKey: savedDatapublishableKeyKey)
        merchantIdField.text = UserDefaults.standard.string(forKey: savedDataMerchantIdKey)
    }
    
    func getFieldsSavedDataText() {
        UserDefaults.standard.set(publishableKeyField.text, forKey: savedDatapublishableKeyKey)
        UserDefaults.standard.set(merchantIdField.text, forKey: savedDataMerchantIdKey)
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
            animateApplePayMerchantIdStackView(shouldShow: uiSwitch.isOn)
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

