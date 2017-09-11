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
  
  enum ApplePayMerchants: String{
 case production = "merchant.com.mycheck"
    case sandbox = "merchant.com.mycheck.sandbox"
  }
 

    @IBOutlet weak var publishableKeyField: UITextField!
    
    @IBOutlet weak var environmentSegControl: UISegmentedControl!
    
    @IBOutlet weak var applePaySwitch: UISwitch!
    
    @IBOutlet weak var payPalSwitch: UISwitch!
    
    @IBOutlet weak var masterPassSwitch: UISwitch!
    
    @IBOutlet weak var visaCheckoutSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishableKeyField.text = UserDefaults.standard.string(forKey: savedDatapublishableKeyKey)
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
        UserDefaults.standard.set(publishableKeyField.text, forKey: savedDatapublishableKeyKey)

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
            guard let merchantId = getSavedDataApplePayMerchandId() else {
                let alert = UIAlertController(title: "Error", message: "Please choose an apple pay merchand id to continue", preferredStyle: .alert)
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
    
    func showMerchantPikerAlert(){
        
        let alert = UIAlertController(title: "Choose an ApplePay Environment", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sandbox", style: .default, handler: {_ in
            self.saveApplePayMerchantId(environment: .sandbox)

        }))
        alert.addAction(UIAlertAction(title: "Production", style: .default, handler:{_ in
            self.saveApplePayMerchantId(environment: .production)
        }))

        present(alert, animated: true, completion: nil)
    }
    
    func clearApplePayMerchantId() {
        UserDefaults.standard.set("", forKey: self.savedDataMerchantIdKey)
    }
    
    func saveApplePayMerchantId (environment : ApplePayMerchants) {
        UserDefaults.standard.set(environment.rawValue, forKey: self.savedDataMerchantIdKey)
    }
    
    func getSavedDataApplePayMerchandId() -> String? {
        return UserDefaults.standard.string(forKey: savedDataMerchantIdKey)!
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
            if uiSwitch.isOn {
                showMerchantPikerAlert()
            } else{
                clearApplePayMerchantId()
            }
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

