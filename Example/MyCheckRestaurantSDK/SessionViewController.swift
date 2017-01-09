//
//  SessionViewController.swift
//  MyCheckRestaurantSDK
//
//  Created by elad schiller on 1/4/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MyCheckRestaurantSDK
class SessionViewController: SuperViewController {

    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var connectionImg: UIImageView!
    @IBOutlet weak var refreshTokenLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      updateLoggedInUI()
        refreshTokenLabel.text = UserDefaults.standard.string(forKey: "refreshToken")
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 // MARK: - actions
    @IBAction func loginPressed(_ sender: Any) {
        if let refresh = refreshTokenLabel.text{
            MyCheck.shared.login(refresh, success: {
               self.updateLoggedInUI()
                UserDefaults.standard.set("eyJpdiI6IlkwRWhvaDBwNHpURWZSRHl3Y3pMZnc9PSIsInZhbHVlIjoiQ0VIU21RS1g1N3FqeWFCdkdIaTdzUT09IiwibWFjIjoiOTE4ZjAwYzAwMWJiZWJhMGRlMDBkZWJjMTIzM2NlYzg3YjdhZGFjNDA4ZTVhMTk5NWM5NjcyMDJmYWZkMGUxYSJ9", forKey: "refreshToken")
                UserDefaults.standard.synchronize()
            
            }, fail: self.fail)
        }
    }
    @IBAction func logoutPressed(_ sender: Any) {
        MyCheck.shared.logout()
        updateLoggedInUI()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private func updateLoggedInUI(){
        connectionLabel.text = MyCheck.shared.isLoggedIn() ? "Logged in" : "Not logged in"
        connectionImg.image = MyCheck.shared.isLoggedIn() ? #imageLiteral(resourceName: "led_green") : #imageLiteral(resourceName: "led_red")
        self.tabBarItem.badgeValue = " "
        if #available(iOS 10.0, *) {
            self.tabBarItem.badgeColor = MyCheck.shared.isLoggedIn() ? UIColor.green : UIColor.red
        } else {
            self.tabBarItem.badgeValue = connectionLabel.text
        }

    }
}

extension SessionViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
