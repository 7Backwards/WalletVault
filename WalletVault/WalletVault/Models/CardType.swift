//
//  CardType.swift
//  WalletVault
//
//  Created by Gonçalo on 16/01/2026.
//

import Foundation

/// Represents different card types with their specific validation rules
enum CardType: String, CaseIterable {
    case visa
    case mastercard
    case amex
    case discover
    case unknown
    
    /// The expected number of digits (without spaces) for this card type
    var numberLength: Int {
        switch self {
        case .amex:
            return 15
        case .visa, .mastercard, .discover, .unknown:
            return 16
        }
    }
    
    /// The expected length of the formatted card number (with spaces)
    var formattedNumberLength: Int {
        switch self {
        case .amex:
            return 17 // 15 digits + 2 spaces (4-6-5 format)
        case .visa, .mastercard, .discover, .unknown:
            return 19 // 16 digits + 3 spaces (4-4-4-4 format)
        }
    }
    
    /// The expected CVV/CVC/CID length for this card type
    var cvvLength: Int {
        switch self {
        case .amex:
            return 4
        case .visa, .mastercard, .discover, .unknown:
            return 3
        }
    }
    
    /// The label to display for the security code field
    var cvvLabel: String {
        switch self {
        case .amex:
            return "CID"
        case .visa, .mastercard, .discover, .unknown:
            return "CVV"
        }
    }
    
    /// Detect the card type from a card number (with or without spaces)
    /// - Parameter cardNumber: The card number to analyze
    /// - Returns: The detected CardType
    static func detect(from cardNumber: String) -> CardType {
        let digits = cardNumber.replacingOccurrences(of: " ", with: "")
        
        guard !digits.isEmpty else {
            return .unknown
        }
        
        // Visa: Starts with 4
        if digits.hasPrefix("4") {
            return .visa
        }
        
        // Mastercard: Starts with 51-55 or 2221-2720
        if digits.range(of: "^(51|52|53|54|55|2221|222[2-9]|22[3-9]\\d|2[3-6]\\d\\d|27[01]\\d|2720)", options: .regularExpression) != nil {
            return .mastercard
        }
        
        // American Express: Starts with 34 or 37
        if digits.range(of: "^(34|37)", options: .regularExpression) != nil {
            return .amex
        }
        
        // Discover: Starts with 6011, 65, or 644-649
        if digits.range(of: "^(6011|65|64[4-9])", options: .regularExpression) != nil {
            return .discover
        }
        
        return .unknown
    }
}
