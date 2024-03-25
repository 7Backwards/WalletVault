//
//  AppUtilsTests.swift
//  SafeWalletTests
//
//  Created by Gonçalo on 10/03/2024.
//

@testable import SafeWallet
import CoreData
import XCTest

class AppUtilsTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testGetFormattedShareCardInfo_ShouldReturnFormattedString() {
        let cardInfo = CardInfo(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", pin: "1234")
        let expectedString = "Card Name: Test Card \nCard Number: 1234567890123456 \nExpiry Date: 12/25 \nCVV: 123 \nCard Pin: 1234"
        let appUtils = AppUtils()
        let formattedString = appUtils.getFormattedShareCardInfo(card: cardInfo)
        XCTAssertEqual(formattedString, expectedString)
    }

    func testGetNonFormattedShareCardInfo_ShouldReturnCommaSeparatedString() {
        let cardInfo = CardInfo(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", pin: "1234")
        let expectedString = "Test Card,1234567890123456,12/25, 123, 1234"
        let appUtils = AppUtils()
        let nonFormattedString = appUtils.getNonFormattedShareCardInfo(card: cardInfo)
        XCTAssertEqual(nonFormattedString, expectedString)
    }

    func testParseCardInfo_WithValidString_ShouldReturnCardInfo() {
        let shareableString = "Test Card,1234567890123456,12/25,123,1234"
        let appUtils = AppUtils()
        let cardInfo = appUtils.parseCardInfo(from: shareableString)
        
        XCTAssertNotNil(cardInfo)
        XCTAssertEqual(cardInfo?.cardName, "Test Card")
    }

    func testParseCardInfo_WithInvalidString_ShouldReturnNil() {
        let shareableString = "Invalid,String"
        let appUtils = AppUtils()
        let cardInfo = appUtils.parseCardInfo(from: shareableString)
        
        XCTAssertNil(cardInfo)
    }

    func testFormatCardNumber_ShouldFormatWithSpaces() {
        let appUtils = AppUtils()
        let rawNumber = "1234567890123456"
        let formattedNumber = appUtils.formatCardNumber(rawNumber)
        let expectedFormattedNumber = "1234 5678 9012 3456"
        XCTAssertEqual(formattedNumber, expectedFormattedNumber)
    }
    
    func testGenerateCardQRCode_ShouldReturnQRCodeImage() {
        let cardInfo = CardInfo(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", pin: "1234")
        let appUtils = AppUtils()
        
        let qrCodeImage = appUtils.generateCardQRCode(from: cardInfo)
        
        XCTAssertNotNil(qrCodeImage)
    }
}



