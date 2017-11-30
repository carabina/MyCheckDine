//
//  PaymentMethodProtocol.swift
//  Pods
//
//  Created by elad schiller on 6/28/17.
//
//

import Foundation

public protocol Chargeable {
func generatePaymentToken(for details: PaymentDetailsProtocol?, displayDelegate: DisplayViewControllerDelegate?, success: @escaping (String) -> Void, fail: @escaping (NSError) -> Void)}

extension Chargeable{
  func generatePaymentToken(for details: PaymentDetailsProtocol? = nil, displayDelegate: DisplayViewControllerDelegate? = nil , success: (_ token: String ) -> Void, fail: (_ error: NSError) -> Void){
  return generatePaymentToken(for: details, displayDelegate: displayDelegate , success: success, fail: fail)
  }
}
