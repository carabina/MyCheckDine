//
//  OrderPoller.swift
//  Pods
//
//  Created by elad schiller on 28/12/2016.
//
//

import UIKit
import MyCheckCore

internal protocol OrderPollerManagerDelegate: OrderPollerDelegate{
  
  func isPolling() -> Bool
}

///When activated this object polls the MyCheck server in order to fetch order updates. Call The startPolling function and set the delegate in order to receive updates. You should generaly use the poller from when a 4 digit code is created untill the order is closed or canceled.
internal class OrderPollerManager : NSObject{
  internal var pollingInterval = 5.0
  private var polling = false
  private var failCount = 0
  
  internal var delayer: DelayInterface = Delay()
  
  ///This variable holds the date of the last time the order was updated.
  public var lastUpdate :Date?
  
  ///Last order received from the server.
  public var order: Order?
  ///This delegate will be called when the order is updated.
  public var delegates  = MulticastDelegate<OrderPollerManagerDelegate>(strongReferences:false)
  
  ///Should be called in order to start polling. Make sure to set a delegate in order to receive order updates.
  public func startPolling(poller: OrderPoller){
    if polling{
      return
    }
    polling = true
    poll()
  }
  
  ///Should be called in order to stop polling. You might still receive a response after it is called in the case that a call was already dispached to the server.
  public func stopPolling(poller: OrderPoller){
    polling = false
    var newPollingValue = false
    
    delegates |> { poller in
      if poller.isPolling(){
        newPollingValue = true
      }
      polling = newPollingValue
    }
  }
  
  
  ///Returns weather the poller is on or not.
  public  func isPolling() -> Bool{
    return polling
  }
  
  
  //The function doing the actaul polling. calls itself again after receiving a response / failing with a 'pollingInterval' delay.
  private func poll(){
    if !polling{
      return
    }
    
    Dine.shared.getOrder(order: order, success: {order in
      
      self.failCount = 0 // only counting consecutive fails.
      self.lastUpdate = Date()
      let  oldOrder = self.order // We want to set self.order before calling the delegate so they match.
      self.order = order
      
      if let new = order ,  let old = oldOrder, new != old{
        
        self.delegates |> {
          $0.orderUpdated(order: new)
        }
        
        
      }else if (order == nil && oldOrder != nil) || (order != nil && oldOrder == nil){
        self.delegates |> {
          $0.orderUpdated(order: order)
        }
        
      }
      
      self.delayer.delay(self.pollingInterval, closure: {//calling poll again.
        self.poll()
      })
      
    }, fail: {error in
      
      if let code = ErrorCodes(rawValue: error.code), code == ErrorCodes.noOpenTable{
        self.failCount = 0
        if let _ = self.order{
          
          self.order = nil
          self.delegates |> {
            $0.orderUpdated(order: nil)
          }
        }
        
      }else{
        self.failCount += 1
      }
      if self.failCount > 2{//in this case we will update the delegate
        self.delegates |> {
          $0.failingToReceiveUpdates(lastReceivedError: error, failCount: self.failCount)
        }
        
        
        
      }
      self.delayer.delay(self.pollingInterval, closure: {//calling poll again.
        self.poll()
      })
      
    }
      
    )
  }
  
  internal func addNewPoller(poller: OrderPollerManagerDelegate){
  delegates += poller
  }
}

