//
//  ShowDineInWebViewController.swift
//  MyCheckDine
//
//  Created by elad schiller on 8/24/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MyCheckDineUIWeb
import MyCheckWalletUI
import MyCheckCore
import MyCheckDine
class ShowDineInWebViewController: ViewController {

    @IBOutlet weak var localeField: UITextField!
    @IBOutlet weak var BIDField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        localeField.addDoneButtonToKeyboard(target: self, action: #selector(self.doneOnKeyboardPressed))
        
        BIDField.addDoneButtonToKeyboard(target:self, action: #selector(self.doneOnKeyboardPressed))
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
    @IBAction func dinePressed(_ sender: Any) {
        
        DineInWebViewControllerFactory.dineIn(at: BIDField.text!, locale: NSLocale(localeIdentifier:localeField.text!) , displayDelegate: self, applePayController: Wallet.shared.applePayController, delegate: self)
    }

    @IBAction func openTablePressed(_ sender: Any) {
        
        Dine.shared.getOrder(success: {order in
            guard let order = order else{
            return
            }
            DineInWebViewControllerFactory.dineInWithOpenOrder(order: order, locale:  NSLocale(localeIdentifier:"en_US"), delegate: self)
        }, fail: nil)
    }
    
  
}

extension ShowDineInWebViewController: DineInWebViewControllerDelegate{

 
    func dineInWebViewControllerCreatedSuccessfully(controller: UIViewController ){
        self.present(controller, animated: true, completion: nil)

    }
    
   
    func dineInWebViewControllerCreatedFailed(error: NSError ){
    
    }
    
    
    func dineInWebViewControllerComplete(controller: UIViewController ,order:Order?, reason:DineInWebViewControllerCompletitionReason){
        controller.dismiss(animated: true, completion: nil)

    }

    
}

extension ShowDineInWebViewController: DisplayViewControllerDelegate{
    
    func display(viewController: UIViewController){
        self.present(viewController, animated: true, completion: nil)

    }
    func dismiss(viewController: UIViewController){
        viewController.dismiss(animated: true, completion: nil)

    }
}

fileprivate extension ShowDineInWebViewController{
   
    @objc func doneOnKeyboardPressed()
    {
        self.BIDField.resignFirstResponder()
        self.localeField.resignFirstResponder()

    }
    
}

