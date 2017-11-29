//
//  DineInWebViewControllerFactory.swift
//  Pods
//
//  Created by elad schiller on 8/16/17.
//
//

import Foundation
import MyCheckWalletUI
import MyCheckCore
import MyCheckDine

/// The various reasons the view controller was dismissed
///
/// - userLeft: The user pressed the x button and decided to leave the dine in flow.
/// - error: An error accaured and forced MyCheck to stop the flow.
/// - completedOrder: The order was paid in full or closed / canceled from the POS.
public enum DineInWebViewControllerCompletitionReason{
    
    case canceled
    
    case error(NSError)
    
    case completedOrder
    
    init?(reason:String, errorCode:Int?, errorMessage:String?){
        
        switch reason{
        case "error":
            
            guard  let errorCode = errorCode,
                let errorMessage = errorMessage else {
                    return nil
            }
            let error = NSError(domain: Session.Const.serverErrorDomain, code: errorCode, userInfo: [NSLocalizedDescriptionKey : errorMessage])
            
            self = .error(error)
            
        case "completedOrder":
            self = .completedOrder
            
        case "canceled":
            self = .canceled
            
        default: return nil
        }
        
        
    }
}

/// Returns updates about the DineInWebViewController that might require actions made by the user of the SDK
public protocol DineInWebViewControllerDelegate{
    
    /// Returns the ViewController that will display the dine in flow if a 4 digit user code was created successfuly
    ///
    /// - Parameter controller: The view controller that should be displaid.
    func dineInWebViewControllerCreatedSuccessfully(controller: UIViewController )
    
    /// Gettin a code failed and thus a view controller was not created
    ///
    /// - Parameter error: The error that caused the failer
    func dineInWebViewControllerCreatedFailed(error: NSError )
    
    /// This function will be called when the view controller needs to be dismissed. It  passes information with the status and reason for completion.
    ///
    ///   - controller: The view controller that must be dismissed.
    ///   - order: The latest state of the order. From this object you can diterman the status of the order, the outstanding balance, how much the user paid etc.
    ///   - reason: The reason for dismissing the view controller.
    func dineInWebViewControllerComplete(controller: UIViewController ,order:Order?, reason:DineInWebViewControllerCompletitionReason)
    
}

/// A static factory class that creates a ViewController that will display the dine in flow
public class DineInWebViewControllerFactory{
    
    
    
    /// Returns a DineInWebViewController with callback after generating a table code.
    ///
    ///   - Parameter businessId: The Id of the business the user wants to dine at
    ///   - Parameter locale: The locale you would like the UI to use
    ///   - Parameter displayDelegate: Only needed when ApplePay is supported. The delegate will be called when the Apple Pay UI needs to be displayed to the user.
    ///   - Parameter applePayController: Enables the use of Apple Pay. you can equire one from the Wallet singleton. When using Apple Pay the parameter must be set or else an error will be returned.
    ///   - Parameter delegate: Will be called when a code is received and pass the ViewController that should be displayed, when the view controller has failed to be created and When the View Controller has complete
    public static func dineIn(at businessId: String ,
                               locale:NSLocale,
                              displayDelegate: DisplayViewControllerDelegate? = nil,
                              applePayController:ApplePayController? = nil,
                              delegate: DineInWebViewControllerDelegate)  {
        
        getURLForNewTable(success: {urlStr in
        
            
            Dine.shared.generateCode(hotelId: nil,
                                     restaurantId: businessId,
                                     displayDelegate: displayDelegate,
                                     applePayController: applePayController ,
                                     success: { code in
                                        let controller = DineInWebViewController(code: code, locale: locale, urlString: urlStr,delegate:delegate)
                                        delegate.dineInWebViewControllerCreatedSuccessfully(controller: controller)
            },
                                     fail: {error in
                                        delegate.dineInWebViewControllerCreatedFailed(error: error)
            })
            
            
        }, fail: {error in
            delegate.dineInWebViewControllerCreatedFailed(error: error)
        })
        
       
        
    }
    
    
    
    /// Returns a DineInWebView that will display an open order
    ///
    ///   - Parameter order: The order that should be displaid to the user. The order must be an open order.
    ///   - Parameter locale: The locale you would like the UI to use.
    ///   - Parameter displayDelegate: Only needed when ApplePay is supported. The delegate will be called when the Apple Pay UI needs to be displayed to the user.
    ///   - Parameter applePayController: Enables the use of Apple Pay. you can equire one from the Wallet singleton. When using Apple Pay the parameter must be set or else an error will be returned.
    ///   - Parameter delegate: The delegate that will update on events you will need to reacte to: display the view controller, dismiss it etc.
    public static func dineInWithOpenOrder(order: Order,
                                           locale:NSLocale,
                                           displayDelegate: DisplayViewControllerDelegate? = nil,
                                           applePayController:ApplePayController? = nil,
                                           delegate: DineInWebViewControllerDelegate) {
       
        getURLForOpenTable(success: { urlStr in
            
            let controller = DineInWebViewController(order: order,
                                                    locale:locale,
                                                    urlString: urlStr,
                                                    delegate: delegate)
            
            delegate.dineInWebViewControllerCreatedSuccessfully(controller:  controller)
            
        }, fail: {error in
        })
        
     }
}

fileprivate extension DineInWebViewControllerFactory{

    
   static func getURLForNewTable(success: @escaping ( String) -> Void , fail: @escaping (NSError) -> Void ){
    
        
        Networking.shared.configure(success: {JSON in
            
            guard let walletWebUI = JSON["dineWebUI"] as? [String: Any],
                let noOpenOrderURL = walletWebUI["noOpenOrderURL"] as? String else{
            fail(ErrorCodes.badJSON.getError())
            return
            }
            
            success( noOpenOrderURL )
            
        }, fail: fail)
    }
    
   static func getURLForOpenTable(success: @escaping ( String) -> Void , fail: @escaping (NSError) -> Void ){
       
        Networking.shared.configure(success: {JSON in
            
            guard let walletWebUI = JSON["dineWebUI"] as? [String: Any],
                let openOrderURL = walletWebUI["openOrderURL"] as? String else{
                    fail(ErrorCodes.badJSON.getError())
                    return
            }
            
            success( openOrderURL )
            
        }, fail: fail)
        
    }
    
    
}
