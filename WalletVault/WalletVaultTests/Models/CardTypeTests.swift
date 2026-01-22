//
//  CardTypeTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 16/01/2026.
//

import XCTest
@testable import WalletVault

final class CardTypeTests: XCTestCase {
    
    // MARK: - Card Type Detection Tests
    
    func testDetectVisaCard() {
        // Visa cards start with 4
        XCTAssertEqual(CardType.detect(from: "4111111111111111"), .visa)
        XCTAssertEqual(CardType.detect(from: "4234 5678 9012 3456"), .visa)
        XCTAssertEqual(CardType.detect(from: "4"), .visa)
    }
    
    func testDetectMastercardCard() {
        // Mastercard: 51-55 or 2221-2720
        XCTAssertEqual(CardType.detect(from: "5111111111111111"), .mastercard)
        XCTAssertEqual(CardType.detect(from: "5555 5555 5555 4444"), .mastercard)
        XCTAssertEqual(CardType.detect(from: "2221000000000000"), .mastercard)
        XCTAssertEqual(CardType.detect(from: "2720999999999999"), .mastercard)
    }
    
    func testDetectAmexCard() {
        // Amex starts with 34 or 37
        XCTAssertEqual(CardType.detect(from: "341111111111111"), .amex)
        XCTAssertEqual(CardType.detect(from: "371449635398431"), .amex)
        XCTAssertEqual(CardType.detect(from: "3782 822463 10005"), .amex)
    }
    
    func testDetectDiscoverCard() {
        // Discover starts with 6011, 65, or 644-649
        XCTAssertEqual(CardType.detect(from: "6011111111111117"), .discover)
        XCTAssertEqual(CardType.detect(from: "6011 1111 1111 1117"), .discover)
        XCTAssertEqual(CardType.detect(from: "6500000000000000"), .discover)
        XCTAssertEqual(CardType.detect(from: "6440000000000000"), .discover)
        XCTAssertEqual(CardType.detect(from: "6490000000000000"), .discover)
    }
    
    func testDetectUnknownCard() {
        XCTAssertEqual(CardType.detect(from: ""), .unknown)
        XCTAssertEqual(CardType.detect(from: "1234567890123456"), .unknown)
        XCTAssertEqual(CardType.detect(from: "9999999999999999"), .unknown)
    }
    
    // MARK: - Number Length Tests
    
    func testAmexNumberLength() {
        XCTAssertEqual(CardType.amex.numberLength, 15)
        XCTAssertEqual(CardType.amex.formattedNumberLength, 17)  // 15 + 2 spaces
    }
    
    func testVisaNumberLength() {
        XCTAssertEqual(CardType.visa.numberLength, 16)
        XCTAssertEqual(CardType.visa.formattedNumberLength, 19)  // 16 + 3 spaces
    }
    
    func testMastercardNumberLength() {
        XCTAssertEqual(CardType.mastercard.numberLength, 16)
        XCTAssertEqual(CardType.mastercard.formattedNumberLength, 19)
    }
    
    func testDiscoverNumberLength() {
        XCTAssertEqual(CardType.discover.numberLength, 16)
        XCTAssertEqual(CardType.discover.formattedNumberLength, 19)
    }
    
    func testUnknownNumberLength() {
        XCTAssertEqual(CardType.unknown.numberLength, 16)
        XCTAssertEqual(CardType.unknown.formattedNumberLength, 19)
    }
    
    // MARK: - CVV Length Tests
    
    func testAmexCVVLength() {
        XCTAssertEqual(CardType.amex.cvvLength, 4)
        XCTAssertEqual(CardType.amex.cvvLabel, "CID")
    }
    
    func testVisaCVVLength() {
        XCTAssertEqual(CardType.visa.cvvLength, 3)
        XCTAssertEqual(CardType.visa.cvvLabel, "CVV")
    }
    
    func testMastercardCVVLength() {
        XCTAssertEqual(CardType.mastercard.cvvLength, 3)
        XCTAssertEqual(CardType.mastercard.cvvLabel, "CVV")
    }
    
    func testDiscoverCVVLength() {
        XCTAssertEqual(CardType.discover.cvvLength, 3)
        XCTAssertEqual(CardType.discover.cvvLabel, "CVV")
    }
    
    func testUnknownCVVLength() {
        XCTAssertEqual(CardType.unknown.cvvLength, 3)
        XCTAssertEqual(CardType.unknown.cvvLabel, "CVV")
    }
}
