//
//  OrderPoller.swift
//  Pods
//
//  Created by elad schiller on 01/10/2017.
//
//

import Foundation
///This delegate will be updated on changes to the users order.
@objc public protocol OrderPollerDelegate {
  
  ///Called when the order was updated.
  ///
  /// - parameter order: The up to date order or nil if their is n order.
  func orderUpdated(order:Order?)
  
  ///Called when the poller fails to receive updates. It is not called on every failed call but rather after a few consecutive fails
  ///
  /// - parameter lastReceivedError:     The error that caused the last server call to fail.
  /// - parameter failCount:     The amount of consecutive calls to the server that failed.
  func failingToReceiveUpdates(lastReceivedError: NSError , failCount:Int)
  
  
}

public class OrderPoller{
  
  // does the poller want to get updates at the moment
  internal var polling = false
  
  internal let delegate: OrderPollerDelegate
  
  
  internal init(delegate: OrderPollerDelegate) {
    self.delegate = delegate
    Dine.shared.pollerManager.addNewPoller(poller: self)
  }
  ///Should be called in order to start polling. Make sure to set a delegate in order to receive order updates.
  public func startPolling(){
    if polling{
      return
    }
    polling = true
    Dine.shared.pollerManager.startPolling(poller: self)
  }
  
  ///Should be called in order to stop polling. You might still receive a response after it is called in the case that a call was already dispached to the server.
  public func stopPolling(){
    polling = false
    Dine.shared.pollerManager.stopPolling(poller: self)

  }
  
   
  
  
}

extension OrderPoller: OrderPollerManagerDelegate{
  
  public func orderUpdated(order:Order?){
    if polling{
      delegate.orderUpdated(order: order)
    }
  }
  
  public func failingToReceiveUpdates(lastReceivedError: NSError , failCount:Int){
    if polling{
      delegate.failingToReceiveUpdates(lastReceivedError: lastReceivedError, failCount: failCount)
    }
  }
  ///Returns weather the poller is on or not.
  public func isPolling() -> Bool{
    return polling
  }
  
  
}
