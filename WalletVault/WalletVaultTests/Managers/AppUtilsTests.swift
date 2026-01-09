//
//  AppUtilsTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 10/03/2024.
//

@testable import WalletVault
import CoreData
import XCTest

class AppUtilsTests: XCTestCase {
    let encryptionKey = AppConstants().encryptionKey
    let appUtils = AppUtils()
    override func setUp() {
        super.setUp()
    }

    func testGetFormattedShareCardInfo_ShouldReturnFormattedString() {
        let cardInfo = CardInfo(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", pin: "1234")
        let expectedString = "Card Name: Test Card \nCard Number: 1234567890123456 \nExpiry Date: 12/25 \nCVV: 123 \nCard Pin: 1234"
        let formattedString = appUtils.getFormattedShareCardInfo(card: cardInfo)
        XCTAssertEqual(formattedString, expectedString)
    }

    func testGetNonFormattedShareCardInfo_ShouldReturnCommaSeparatedString() {
        let cardInfo = CardInfo(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", pin: "1234")
        let expectedString = "Test Card,1234567890123456,12/25, 123, 1234"
        let nonFormattedString = appUtils.getShareCardCode(card: cardInfo, key: AppConstants().encryptionKey)
        XCTAssertEqual(nonFormattedString, expectedString)
    }

    func testParseCardInfo_WithValidString_ShouldReturnCardInfo() {
        let shareableString = appUtils.encryptString("Test Card,1234567890123456,12/25,123,1234", using: encryptionKey) ?? ""
        let cardInfo = appUtils.parseCardInfo(from: shareableString, using: encryptionKey)
        
        XCTAssertNotNil(cardInfo)
        XCTAssertEqual(cardInfo?.cardName, "Test Card")
    }

    func testParseCardInfo_WithInvalidString_ShouldReturnNil() {
        let shareableString = appUtils.encryptString("Invalid,String", using: encryptionKey) ?? ""
        let cardInfo = appUtils.parseCardInfo(from: shareableString, using: encryptionKey)
        
        XCTAssertNil(cardInfo)
    }

    func testFormatCardNumber_ShouldFormatWithSpaces() {
        let rawNumber = "1234567890123456"
        let formattedNumber = appUtils.formatCardNumber(rawNumber)
        let expectedFormattedNumber = "1234 5678 9012 3456"
        XCTAssertEqual(formattedNumber, expectedFormattedNumber)
    }
    
    func testGenerateCardQRCode_ShouldReturnQRCodeImage() {
        let cardInfo = CardInfo(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", pin: "1234")
        let string = appUtils.getShareCardCode(card: cardInfo, key: encryptionKey) ?? ""
        let qrCodeImage = appUtils.generateCardQRCode(from: string)
        
        XCTAssertNotNil(string)
        XCTAssertNotNil(qrCodeImage)
    }
}



