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
            UserDefaults.standard.set("pk_fXACc6bLgs3zECbwSZyaXl7NrIa9P", forKey: "publishableKey")
            UserDefaults.standard.set("2", forKey: "BID")
            UserDefaults.standard.set("merchant.com.mycheck", forKey: "ApplePayMerchantId")


            UserDefaults.standard.set("eyJpdiI6Ik5xM3ZsanAxdlFJUk1oQlpUN1NaZFE9PSIsInZhbHVlIjoiS2pXNHBxdlNodWNTcDJBbkV2VHlyVjZWbmFwMkxWOSs1QVwvZVVQR29VUzd4QVRCeEY3N00rclliUjVZVUVMRXpDTEp6MGZ4Y1V6cjJDVlwvZlFVWG1aUER5dStQVDV1amFOeGt5VGQyNDRoNnBjZ05ad3J4RW5WK1wvOXJBdllDRDNsT0ljcllIOTBBUnNHV01WaG5cL2pMU2hGcUVzbys0enYzbnBSa0RlaHZHOD0iLCJtYWMiOiI5NzZlZjhlN2ZlZTY5NWJiM2ZkYzI2ZjI4MmEyNzY2OTljNzVkMWU1YTlmMmU4MDljYzc2Y2I0ZDYwNGZhMmJiIn0=", forKey: "refreshToken")
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

