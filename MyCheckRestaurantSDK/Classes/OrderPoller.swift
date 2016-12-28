//
//  OrderPoller.swift
//  Pods
//
//  Created by elad schiller on 28/12/2016.
//
//

import UIKit

///This delegate will be updated on changes to the users Order.
public protocol OrderPollerDelegate {
  
  ///called when the order was updated.
  ///
  /// - parameter order:     The up to date order.
  func orderUpdated(order:Order)
  
  ///called when the poller fails to receive updates. It is not called on every failed call but rather after a few consecutive fails
  ///
  /// - parameter lastReceivedError:     The error that caused the last server call to fail.
  /// - parameter failCount:     The amount of consecutive calls to the server that failed.
  func failingToReceiveUpdates(lastReceivedError: Error , failCount:Int)
}
public class OrderPoller {
  private let pollingInterval = 5.0
  private var polling = false
  private var failCount = 0
  
  
  ///This variable holds the date of the last time the order was updated.
  var lastUpdate :Date?
  
  ///Last order received from the server.
  var order: Order?
  ///This delegate will be called when the order is updated.
  var delegate :OrderPollerDelegate?
  
  ///Should be called to start polling. make sure to set a delegate in order to receive order updates.
  func startPolling(){
    if polling{
    return
    }
    polling = true
    poll()
  }
  
  ///Should be called in order to stop polling. You might still receive a response after it is called in the case that a call was already dispached to the server.
  func stopPolling(){
    polling = false
  }
  
  ///Returns weather the poller is On or not
  func isPolling() -> Bool{
    return polling
  }
  
  
  //The function doing the actaul polling. calls itself again after receiving a response / failing with a 'pollingInterval' delay.
  private func poll(){
    if !polling{
      return
    }
    
    MyCheck.shared.getOrder(success: {order in
      
      self.failCount = 0 // only counting consecutive fails.
      self.lastUpdate = Date()
      let  oldOrder = self.order // We want to set self.order before calling the delegate so they match.
      self.order = order

      if oldOrder == nil || order.md5 != oldOrder?.md5{
        if let delegate = self.delegate{
          delegate.orderUpdated(order: order)
          
        }
      }
      delay(self.pollingInterval, closure: {//calling poll again.
      self.poll()
      })
      
    }, fail: {error in
      self.failCount += 1
      if self.failCount > 2{//in this case we will update the delegate
        
        if let delegate = self.delegate{
          delegate.failingToReceiveUpdates(lastReceivedError: error, failCount: self.failCount)
        }
      
      }
      delay(self.pollingInterval, closure: {//calling poll again.
        self.poll()
      })
      
    }
    
    )
  }
}
