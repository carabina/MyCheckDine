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
        
        connectionLabel.text = MyCheck.shared.isLoggedIn() ? "Connected" : "Disconnected"
        connectionImg.image = MyCheck.shared.isLoggedIn() ? #imageLiteral(resourceName: "led_green") : #imageLiteral(resourceName: "led_red")
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
                self.connectionImg.image =  #imageLiteral(resourceName: "led_green")
                self.connectionLabel.text =  "Connected"

                UserDefaults.standard.set("eyJpdiI6ImErWVpjVE9HZG11ZDNQWHBwd1VpRWc9PSIsInZhbHVlIjoiS3VkVnhMZHkxYUo1WlNBOTllZ2hrdz09IiwibWFjIjoiZWExOTFkNjkzYzIyZmJhOGM3NDNkMThiN2MyMDRmODg1YzMwOThiY2NmMzJkM2EyOWM0Y2I2NTg0YTUxMDAyOCJ9", forKey: "refreshToken")
                UserDefaults.standard.synchronize()
            
            }, fail: self.fail)
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
