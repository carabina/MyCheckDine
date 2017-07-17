//
//  ApplePayStateInterface.swift
//  Pods
//
//  Created by elad schiller on 6/25/17.
//
//

import Foundation
///will answer and update applepay specific logic
public protocol ApplePayController {
  
    /// Is apple pay the default payment method
    ///
    /// - Returns: true if it is
    func isApplePayDefault() -> Bool
  
    /// Change the default state of apple pay
    ///
    /// - Parameter newDefault: The new value to be set
    func changeApplePayDefault(to newDefault: Bool)
  
  /// Get a payment method that reprisents Apple Pay
  ///
  /// - Returns: The Apple Pay payment method object
  func getApplePayPaymentMethod() -> PaymentMethodInterface?
  
  /// Returns true iff the user can make a payment using Apple Pay. This means the device supports Apple Pay,  that their is a card in the Apple wallet and that the card belongs to one of the supported payment methods.
  ///
  /// - Returns: true if the user can make a payment with Apple Pay
  func canPayWithApplePay() -> Bool
  
  /// Returns true iff the device supports Apple Pay and the SDK is configured to use it. This doesnt mean he can make payments. he might not be able to because their is no card in the Apple wallet for example.
  ///
  /// - Returns: true if the device supports Apple Pay and ApplePay is configured for use with the SDK.
  func applePayConfigured() -> Bool
}