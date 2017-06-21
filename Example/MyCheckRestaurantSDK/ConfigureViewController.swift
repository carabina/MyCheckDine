//
//  ConfigureViewController.swift
//  MyCheckRestaurantSDK
//
//  Created by elad schiller on 1/3/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MyCheckCore
import MyCheckRestaurantSDK
import MyCheckWalletUI
class ConfigureViewController: UIViewController {
    
    @IBOutlet weak var publishableKeyField: UITextField!
    
    @IBOutlet weak var environmentSegControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishableKeyField.text = UserDefaults.standard.string(forKey: "publishableKey")
        
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
            if LocalData.enabledState(for: .payPal){
                PaypalFactory.initiate("com.mycheck.MyCheckRestaurantSDK-Example")
                
            }
            performSegue(withIdentifier: "pushMainApp", sender: nil)
            
        }else{
            let alert = UIAlertController(title: "Error", message: "Please enter publishable key to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
