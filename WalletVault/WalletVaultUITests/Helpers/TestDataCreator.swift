//
//  TestDataCreator.swift
//  WalletVaultUITests
//
//  Created by Gonçalo on 15/01/2026.
//

import Foundation

struct TestCardData {
    let name: String
    let number: String
    let expiry: String
    let cvv: String
    let pin: String?
    
    static func validCard(name: String = "Test Card") -> TestCardData {
        return TestCardData(
            name: name,
            number: "4234 5678 9012 3456",
            expiry: "12/28",
            cvv: "123",
            pin: "1234"
        )
    }
    
    static func visaCard() -> TestCardData {
        return TestCardData(
            name: "Visa Card",
            number: "4111 1111 1111 1111",
            expiry: "12/28",
            cvv: "123",
            pin: nil
        )
    }
    
    static func mastercardCard() -> TestCardData {
        return TestCardData(
            name: "Mastercard",
            number: "5555 5555 5555 4444",
            expiry: "01/29",
            cvv: "456",
            pin: "5678"
        )
    }
    
    static func amexCard() -> TestCardData {
        return TestCardData(
            name: "American Express",
            number: "3782 822463 10005",  // 15 digits in 4-6-5 format
            expiry: "06/29",
            cvv: "1234",  // 4-digit CID for Amex
            pin: nil
        )
    }
    
    static func discoverCard() -> TestCardData {
        return TestCardData(
            name: "Discover Card",
            number: "6011 1111 1111 1117",
            expiry: "09/29",
            cvv: "789",
            pin: nil
        )
    }
    
    static func invalidCardNumber() -> TestCardData {
        return TestCardData(
            name: "Invalid Card",
            number: "1234",  // Too short
            expiry: "12/28",
            cvv: "123",
            pin: nil
        )
    }
    
    static func expiredCard() -> TestCardData {
        return TestCardData(
            name: "Expired Card",
            number: "4234 5678 9012 3456",
            expiry: "12/20",  // Past date
            cvv: "123",
            pin: nil
        )
    }
    
    static func invalidExpiry() -> TestCardData {
        return TestCardData(
            name: "Invalid Expiry",
            number: "4234 5678 9012 3456",
            expiry: "13/28",  // Invalid month
            cvv: "123",
            pin: nil
        )
    }
    
    static func malformedExpiry() -> TestCardData {
        return TestCardData(
            name: "Malformed Expiry",
            number: "4234 5678 9012 3456",
            expiry: "12-28",  // Wrong separator
            cvv: "123",
            pin: nil
        )
    }
    
    static func emptyFields() -> TestCardData {
        return TestCardData(
            name: "",
            number: "",
            expiry: "",
            cvv: "",
            pin: nil
        )
    }
    
    /// Generate multiple test cards
    static func multipleCards(count: Int = 5) -> [TestCardData] {
        var cards: [TestCardData] = []
        let names = ["Personal Visa", "Business Mastercard", "Travel Visa", "Amex Gold", "Discover It"]
        let numbers = [
            "4234 5678 9012 3456",    // Visa (16 digits)
            "5555 5555 5555 4444",    // Mastercard (16 digits)
            "4111 1111 1111 1111",    // Visa (16 digits)
            "3782 822463 10005",      // Amex (15 digits, 4-6-5 format)
            "6011 1111 1111 1117"     // Discover (16 digits)
        ]
        let cvvs = ["123", "456", "789", "1234", "321"]  // Amex has 4-digit CVV
        
        for i in 0..<min(count, names.count) {
            cards.append(TestCardData(
                name: names[i],
                number: numbers[i],
                expiry: "12/\(30 + i)",
                cvv: cvvs[i],
                pin: i % 2 == 0 ? "\(1000 + i)" : nil
            ))
        }
        
        return cards
    }
}
