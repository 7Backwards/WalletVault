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
        let expectedString = "\(NSLocalizedString("Card Name", comment: "")): Test Card \n\(NSLocalizedString("Card Number", comment: "")): 1234567890123456 \n\(NSLocalizedString("Expiry Date", comment: "")): 12/25 \n\(NSLocalizedString("CVV", comment: "")): 123 \n\(NSLocalizedString("Card Pin", comment: "")): 1234"
        let formattedString = appUtils.getFormattedShareCardInfo(card: cardInfo)
        XCTAssertEqual(formattedString, expectedString)
    }

    func testGetShareCardCode_ShouldReturnEncryptedString() {
        let cardInfo = CardInfo(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", pin: "1234")
        let encryptedString = appUtils.getShareCardCode(card: cardInfo, key: encryptionKey)
        XCTAssertNotNil(encryptedString)
        XCTAssertNotEqual(encryptedString, "Test Card|;|1234567890123456|;|12/25|;|123|;|1234")
        
        // Verify it can be decrypted back
        let decryptedInfo = appUtils.parseCardInfo(from: encryptedString!, using: encryptionKey)
        XCTAssertEqual(decryptedInfo?.cardName, "Test Card")
        XCTAssertEqual(decryptedInfo?.cardNumber, "1234567890123456")
    }

    func testParseCardInfo_WithValidString_ShouldReturnCardInfo() {
        let shareableString = appUtils.encryptString("Test Card|;|1234567890123456|;|12/25|;|123|;|1234", using: encryptionKey) ?? ""
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
    
    func testFormatAmexCardNumber_ShouldFormatWith465Pattern() {
        // Amex cards start with 34 or 37 and have 15 digits
        let rawNumber = "378282246310005"
        let formattedNumber = appUtils.formatCardNumber(rawNumber)
        let expectedFormattedNumber = "3782 822463 10005"  // 4-6-5 format
        XCTAssertEqual(formattedNumber, expectedFormattedNumber)
    }
    
    func testFormatVisaCardNumber_ShouldLimit16Digits() {
        // Visa cards should be limited to 16 digits
        let rawNumber = "41111111111111112222"  // 20 digits
        let formattedNumber = appUtils.formatCardNumber(rawNumber)
        XCTAssertEqual(formattedNumber.replacingOccurrences(of: " ", with: "").count, 16)
    }
    
    func testFormatAmexCardNumber_ShouldLimit15Digits() {
        // Amex cards should be limited to 15 digits
        let rawNumber = "3782822463100052222"  // 19 digits starting with 37
        let formattedNumber = appUtils.formatCardNumber(rawNumber)
        XCTAssertEqual(formattedNumber.replacingOccurrences(of: " ", with: "").count, 15)
    }
    
    func testGetCardIssuerImage_Discover() {
        // Discover cards start with 6011
        let discoverImage = appUtils.getCardIssuerImage(cardNumber: "6011 1111 1111 1117")
        XCTAssertNotNil(discoverImage)
        
        // Discover cards starting with 65
        let discoverImage2 = appUtils.getCardIssuerImage(cardNumber: "6500 0000 0000 0000")
        XCTAssertNotNil(discoverImage2)
    }
    
    func testGenerateCardQRCode_ShouldReturnQRCodeImage() {
        let cardInfo = CardInfo(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", pin: "1234")
        let string = appUtils.getShareCardCode(card: cardInfo, key: encryptionKey) ?? ""
        let qrCodeImage = appUtils.generateCardQRCode(from: string)
        
        XCTAssertNotNil(string)
        XCTAssertNotNil(qrCodeImage)
    }
}



