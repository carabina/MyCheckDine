//
//  BenefitRedeemResult.swift
//  MyCheckDine
//
//  Created by elad schiller on 12/31/17.
//

import Foundation


/// Discribes the result of redeeming a benefit. 
public struct BenefitRedeemResult{
    
    
    private  let successOutcome = 12001
    /// The outcome code
    let outcome: Int
    /// True if the benefit was redeemed successfully
    let success: Bool
    /// The benefit Id as specified by the provider
    let providerBenefitId: String
    /// The provider name
    let provider: String
    /// The error key. Is nil when the benefit is redeemed successfully
    let error: String?
    /// The error message. Is nil when the benefit is redeemed successfully
    let errorMessage: String?
    
    ///The constructor of the struct
    ///
    ///   - JSON: The JSON object received
    public init?(JSON: [String: Any]) {
        guard let outcome = JSON["outcome"] as? Int,
            let providerId = JSON["provider_benefit_id"] as? String,
            let provider = JSON["provider"] as? String else{
                return nil
        }
        self.outcome = outcome
        self.success = outcome == successOutcome
        self.providerBenefitId = providerId
        self.provider = provider
        error = JSON["error"] as? String
        errorMessage = JSON["message"] as? String
        
    }
    
    
    public func JSONify() -> [String: Any] {
        var JSON = ["outcome": outcome,
                    "success": success,
                    "provider_benefit_id": providerBenefitId,
                    "provider": provider] as [String : Any]
        
        if let error = error,
            let errorMessage = errorMessage{
            JSON["error"] = error
            JSON["message"] = errorMessage
        }
        return JSON
    }
}
