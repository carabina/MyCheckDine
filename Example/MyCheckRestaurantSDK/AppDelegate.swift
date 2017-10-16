//
//  AppDelegate.swift
//  MyCheckDine
//
//  Created by elad schillerrr on 12/25/2016.
//  Copyright (c) 2016 MyCheck LTD. All rights reserved.
//

import UIKit
import MyCheckCore
import MyCheckDine
import MyCheckWalletUI
import PassKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        _ = TerminalModel.shared // initializing the terminal singleton
        
        Session.logDebugData = true
       
        if !UserDefaults.standard.bool(forKey: "notFirstLaunch"){
            UserDefaults.standard.set("pk_ZEhw02iTIxloK51VDcYW4sAdIDC9V", forKey: "publishableKey")
            UserDefaults.standard.set("2", forKey: "BID")
            UserDefaults.standard.set("merchant.com.mycheck", forKey: "ApplePayMerchantId")


            UserDefaults.standard.set("eyJpdiI6ImY4a2xUNndqR0dcL0hFU0Qya21vdEt3PT0iLCJ2YWx1ZSI6Imwzak8zWUZMenBHQ0pidFllY1wvRXFXR2Q4Y0RwWEJIWjVPT3lQeXdSNlFrRExqM09ZQkxTNWxBNlVJMjkrOU1lMnp4TXhuT1BGSzFjY1h1YmNFdGZcL2oxa0xsaWU1a25MK296ZFgwa0piQ2U5dHhjVkNXOWthNGR3eUFkeXBOUG5RZ0ZZcGwxM0d1SzdqTmltVTllUEVkWjZhNG5aMzh1VndVSHBpWlNnd2Y3cmdyTnBKQU0ycWZ0XC9TbiszVmZJZiIsIm1hYyI6Ijc3N2Y3ZjI2NjE4ZmVhOGQyMTIyMTkzMGZkNjY5N2I5YjY2N2RkMzg2MTQxODI5ZGY1Mzg1NThkMjJlMTMzOTIifQ==", forKey: "refreshToken")
            UserDefaults.standard.set(true, forKey: "notFirstLaunch")
             UserDefaults.standard.synchronize()

        }
        
       
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

