
//
//  NativeCallHandler.swift
//  Pods
//
//  Created by elad schiller on 8/7/17.
//
//

import Foundation
import WebKit
import MyCheckCore
import MyCheckDine
class NativeCallHandler: NSObject, WKScriptMessageHandler {
  
  var interactor: DineInWebBusinessLogic
  
  init(interactor: DineInWebBusinessLogic) {
    self.interactor = interactor
  }
    
    deinit {
        print("deinit NativeCallHandler")
    }
    
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
  
    
    guard let jsonString: String = message.body as? String,
      let jsonData = jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)),
      let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as!NSDictionary,
      let action = jsonDictionary["action"] as? String else{
        return
    }
    let callback = jsonDictionary["callback"] as? String ?? ""
    
    switch action{
      
    case "getClientCode":
      
      let request = DineInWeb.GetCode.Request(callback: callback)
      interactor.getCodeRequested(request: request)
    
    case "startPolling":
      let request = DineInWeb.Poll.Request(pollingOn:true, callback: callback)
      interactor.toggleOrderDetailsPolling(request: request)
      
    case "stopPolling":
      let request = DineInWeb.Poll.Request(pollingOn:false, callback: callback)
      interactor.toggleOrderDetailsPolling(request: request)
      
    case "getOrderDetails":
    getOrderDetails(callback: callback, JSON: jsonDictionary)
      
    case "getPaymentMethods":
      let request = DineInWeb.PaymentMethods.Request(callback: callback)
      interactor.getPaymentMethods(request: request)
    
    case "generatePaymentRequest":
        callGeneratePaymentRequest(callback: callback, JSON: jsonDictionary)

    case "makePayment":
      makePayment(callback: callback, JSON: jsonDictionary)

    case "reorderItems":
      reorderItems(callback: callback, JSON: jsonDictionary)
      
    case "completeDineIn":
      completeDineIn(callback: callback, JSON: jsonDictionary)
  
    case "getFriendsList":
      let request = DineInWeb.GetFriendsList.Request(callback:callback)
      interactor.getFriendList(request: request)
  
    case "addFriend":
    addAFriend(callback: callback, JSON: jsonDictionary)
      
    case "sendFeedback":
      sendFeedback(callback: callback, JSON: jsonDictionary)
        
    case "callWaiter":
      let request = DineInWeb.CallWaiter.Request(callback: callback)
      interactor.callWaiter(request: request)
  
    case "getLocale":
        let request = DineInWeb.getLocale.Request(callback: callback)
        interactor.getLocale(request: request)
    case "getBenefits":
        getBenefits(callback: callback, JSON: jsonDictionary)
        
    case "redeemBenefit":
        redeemBenefit(callback: callback, JSON: jsonDictionary)
    default: break
      
    }
    
  }
  
  
}


fileprivate extension NativeCallHandler{
  
    func callGeneratePaymentRequest(callback: String, JSON: NSDictionary){
        
        guard let body = JSON["body"] as? [String:Any] ,
            let tip = body["tip"] as? Double else{
            interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
            return
        }
        
        if let itemsJSON = body["items"] as? [[String:Any]] , itemsJSON.count > 0{
            
            generatePaymentRequestByItems(callback: callback, itemsJSON: itemsJSON ,tip: tip)
            return 
            
        }
        
       if let amount = body["amount"] as? Double,
        let tip = body["tip"] as? Double{
            
            generatePaymentRequestByAmount(callback: callback, amount: amount, tip: tip)
        return
        }
        
        if let amountStr = body["amount"] as? String,
            let amount = Double( amountStr),
            let tip = body["tip"] as? Double{
            
            generatePaymentRequestByAmount(callback: callback, amount: amount, tip: tip)
            return
        }
        
        guard let full = body["payFullAmount"] as? Bool,
            full == true else{// non of the options apply so fail
                interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
return
        }
        generatePaymentRequestForFullTable(callback: callback, tip: tip)
    }
    
    func generatePaymentRequestByAmount(callback: String, amount: Double, tip: Double){
       
       
        let request = DineInWeb.GeneratePayRequest.Request(callback: callback,
                                            payFor: .amount(amount),
                                            tip: tip)
        interactor.callGeneratePaymentRequest(request: request)
        
        
    }
    
    func generatePaymentRequestByItems(callback: String, itemsJSON: [[String: Any]], tip: Double){
       
        let items = itemsJSON.map{ BasicItem(json:$0)}.flatMap{$0}
        
        let request = DineInWeb.GeneratePayRequest.Request(callback: callback, payFor: .items(items), tip: tip)
        interactor.callGeneratePaymentRequest(request: request)
    }
    
    func generatePaymentRequestForFullTable(callback: String, tip: Double){

        let request = DineInWeb.GeneratePayRequest.Request(callback: callback, payFor: .fullAmount , tip: tip)
        interactor.callGeneratePaymentRequest(request: request)
    }
    
    
    
    
    func makePayment(callback: String, JSON: NSDictionary){

    guard let body = JSON["body"] as? [String:Any] else{
        interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
      return
    }
    
    
    
    guard let paymentMethod = body["paymentMethod"] as? [String: Any],
      let methodToken = paymentMethod["token"] as? String,
      let methodsource = paymentMethod["source"] as? String
      
      
      else{
        
          interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
        return;
    }
    var methodIdString : String? = nil
    if  let methodIDNum = paymentMethod["id"] as? Int{

     methodIdString = String(methodIDNum)
    }else{
        
         methodIdString = paymentMethod["id"] as? String

    }
    guard let methodId = methodIdString else{
          interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
        return
        }
        var tip = 0.0 as Double
        if let tipString = body["tip"] as? String,
        let tipDouble = Double( tipString){
           tip = tipDouble
        }

    let methodType = PaymentMethodType(source: methodsource)
    
    let request = DineInWeb.Pay.Request(callback: callback,
                                        tip: tip,
                                        paymentMethodId: methodId,
                                        paymentMethodToken: methodToken,
                                        paymentMethodType: methodType)
    interactor.makePayment(request: request)
    
    
  }
  
 
  func reorderItems(callback: String, JSON: NSDictionary){
    guard let body = JSON["body"] as? [String:Any],
      let itemsJSON = body["items"] as? [[String:Any]]
      else{
          interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
        return;
    }
    let items = itemsJSON.map{ Item(json:$0)}.flatMap{$0}
    let amountItemTupleArr = items.map{($0.quantity , $0)}
    
    let request = DineInWeb.Reorder.Request(callback: callback, items: amountItemTupleArr)
    interactor.reorderItems(request: request)
  }
  
  func completeDineIn(callback: String, JSON: NSDictionary){
    guard let body = JSON["body"] as? [String:Any],
      let reasonString = body["reason"] as? String
      
      else{
          interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
        return;
    }
    
    if let reason = DineInWebViewControllerCompletitionReason(reason: reasonString, errorCode: body["errorCode"] as? Int, errorMessage: body["errorMessage"] as? String){
      
      let request = DineInWeb.Complete.Request(reason: reason, callback: callback)
      
      interactor.complete(request: request)
    }
  }
  
  func addAFriend(callback: String, JSON: NSDictionary){
    guard let body = JSON["body"] as? [String:Any] ,
      let code = body["code"] as? String
      else{
          interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
        return
    }
    let request = DineInWeb.AddAFriend.Request(callback: callback, code: code)
    interactor.AddAFriend(request: request)
  }
  
  func sendFeedback(callback: String, JSON: NSDictionary){
    guard let body = JSON["body"] as? [String:Any] ,
      let orderId = body["orderId"] as? String,
      let stars = body["stars"] as? Int

      else{
          interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
        return
    }
    
    let comment = body["comment"] as? String
    
    let request = DineInWeb.SendFeedback.Request(callback: callback, orderId: orderId, stars: stars, comment: comment)
    interactor.sendFeedback(request: request)
  }

  func getOrderDetails(callback: String, JSON: NSDictionary){
    
    
    let body : [String: Any] = JSON["body"] as?  [String: Any] ?? [:]
    
    let cache =  body["isCachedOrder"] as? Bool ?? false // if no value dont use cache
   
    let request = DineInWeb.GetOrderDetails.Request(callback: callback, cache: cache)
    interactor.getOrderDetails(request: request)
  }
  
    func getBenefits(callback: String, JSON: NSDictionary){
        
        
        let body : [String: Any] = JSON["body"] as?  [String: Any] ?? [:]
        
        guard  let restaurantId =  body["restaurantId"] as? String? else {
            interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
          return
          
      }
        
        let request = DineInWeb.getBenefits.Request(callback: callback, restaurantId: restaurantId)
        interactor.getBenefits(request: request)
    }
    
    func redeemBenefit(callback: String, JSON: NSDictionary){
        
        
        let body : [String: Any] = JSON["body"] as?  [String: Any] ?? [:]
        
        let restaurantId =  body["restaurantId"] as? String
        guard let benefitJSON = body["benefit"] as? [String: Any],
            let benefit = Benefit(JSON: benefitJSON) else{
                interactor.displayError(request: DineInWeb.DisplayError.Request(error: ErrorCodes.badJSON.getError(), callback: callback))
              return
        }
        let request = DineInWeb.RedeemBenefit.Request(callback: callback, restaurantId: restaurantId, benefit: benefit)
        interactor.redeemBenefits(request: request)
    }
}
