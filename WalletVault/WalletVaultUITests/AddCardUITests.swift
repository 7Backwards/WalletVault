//
//  AddCardUITests.swift
//  WalletVaultUITests
//
//  Created by Gonçalo on 15/01/2026.
//

import XCTest

final class AddCardUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchForUITesting(disableBiometricAuth: true, clearData: true)
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    func openAddCardSheet() {
        dismissKeyboard(in: app)
        let addButton = app.buttons[UITestIdentifiers.addCardButton]
        XCTAssertTrue(waitForElement(addButton, timeout: 10), "Add button should be visible")
        addButton.tap()
        
        let cardNameField = app.textFields[UITestIdentifiers.cardNameField]
        XCTAssertTrue(waitForElement(cardNameField, timeout: 5), "Add card sheet should open")
    }
    
    func fillCardDetails(_ cardData: TestCardData) {
        fillTextField(app.textFields[UITestIdentifiers.cardNameField], with: cardData.name)
        fillTextField(app.textFields[UITestIdentifiers.cardNumberField], with: cardData.number)
        fillTextField(app.textFields[UITestIdentifiers.expiryDateField], with: cardData.expiry)
        fillTextField(app.textFields[UITestIdentifiers.cvvField], with: cardData.cvv)
        
        if let pin = cardData.pin {
            fillTextField(app.textFields[UITestIdentifiers.pinField], with: pin)
        }
    }
    
    // MARK: - UI Elements Tests
    
    func testAllInputFieldsArePresent() throws {
        openAddCardSheet()
        
        XCTAssertTrue(app.textFields[UITestIdentifiers.cardNameField].exists, "Card name field should exist")
        XCTAssertTrue(app.textFields[UITestIdentifiers.cardNumberField].exists, "Card number field should exist")
        XCTAssertTrue(app.textFields[UITestIdentifiers.expiryDateField].exists, "Expiry date field should exist")
        XCTAssertTrue(app.textFields[UITestIdentifiers.cvvField].exists, "CVV field should exist")
        XCTAssertTrue(app.textFields[UITestIdentifiers.pinField].exists, "PIN field should exist")
        XCTAssertTrue(app.buttons[UITestIdentifiers.saveButton].exists, "Save button should exist")
    }
    
// MARK: - Valid Data Tests
    
    func testAddCardWithValidData() throws {
        openAddCardSheet()
        
        let validCard = TestCardData.validCard(name: "Test Visa")
        fillCardDetails(validCard)
        
        let saveButton = app.buttons[UITestIdentifiers.saveButton]
        XCTAssertTrue(saveButton.exists, "Save button should be visible")
        
        // Dismiss keyboard to ensure save button is hittable
        dismissKeyboard(in: app)
        
        saveButton.tap()
        
        // Sheet should dismiss after successful save
        let cardNameField = app.textFields[UITestIdentifiers.cardNameField]
        if !waitForElementToDisappear(cardNameField, timeout: 10) {
            logAlerts(in: app)
            XCTFail("Add card sheet should dismiss after saving")
        }
    }
    
    func testAddMultipleCards() throws {
        let cards = [
            TestCardData.visaCard(),
            TestCardData.mastercardCard()
        ]
        
        for (index, card) in cards.enumerated() {
            openAddCardSheet()
            fillCardDetails(card)
            
            let saveButton = app.buttons[UITestIdentifiers.saveButton]
            XCTAssertTrue(waitForElement(saveButton, timeout: 5), "Save button should exist")
            
            // Dismiss keyboard to ensure save button is hittable
            dismissKeyboard(in: app)
            
            saveButton.tap()
            
            let cardNameField = app.textFields[UITestIdentifiers.cardNameField]
            if !waitForElementToDisappear(cardNameField, timeout: 15) {
                logAlerts(in: app)
                printHierarchy(in: app)
                XCTFail("Sheet should dismiss for card \(index + 1)")
            }
            
            // Wait for UI to settle before next card
            XCWait(2)
        }
        
        // Verify cards are visible in list (cards should be shown, not empty state)
        let noCardsView = app.otherElements[UITestIdentifiers.noCardsView]
        XCTAssertFalse(noCardsView.exists, "Empty state should not be shown when cards exist")
    }
    
    // MARK: - Validation Tests
    
    func testSaveWithEmptyFieldsShowsError() throws {
        openAddCardSheet()
        
        // Try to save without filling anything
        let saveButton = app.buttons[UITestIdentifiers.saveButton]
        saveButton.tap()
        
        // Sheet should not dismiss (validation should prevent save)
        let cardNameField = app.textFields[UITestIdentifiers.cardNameField]
        XCTAssertTrue(cardNameField.exists, "Add card sheet should remain open when validation fails")
    }
    
    func testInvalidCardNumberShowsError() throws {
        openAddCardSheet()
        
        let invalidCard = TestCardData.invalidCardNumber()
        fillCardDetails(invalidCard)
        
        app.buttons[UITestIdentifiers.saveButton].tap()
        
        // Wait for alert to appear
        let alert = app.alerts.firstMatch
        XCTAssertTrue(waitForElement(alert, timeout: 2), "Error alert should appear for invalid card number")
        XCTAssertTrue(alert.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'invalid'")).firstMatch.exists, 
                      "Alert should mention invalid card number")
    }
    
    func testExpiredDateShowsError() throws {
        openAddCardSheet()
        
        let expiredCard = TestCardData.expiredCard()
        fillCardDetails(expiredCard)
        
        app.buttons[UITestIdentifiers.saveButton].tap()
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(waitForElement(alert, timeout: 2), "Error alert should appear for expired card")
        XCTAssertTrue(alert.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'date'")).firstMatch.exists,
                      "Alert should mention date issue")
    }
    
    func testInvalidExpiryMonthShowsError() throws {
        openAddCardSheet()
        
        let invalidCard = TestCardData.invalidExpiry()
        fillCardDetails(invalidCard)
        
        app.buttons[UITestIdentifiers.saveButton].tap()
        
        let alert = app.alerts.firstMatch
        XCTAssertTrue(waitForElement(alert, timeout: 2), "Error alert should appear for invalid expiry month")
        XCTAssertTrue(alert.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'date'")).firstMatch.exists,
                      "Alert should mention date issue")
    }
    
    // MARK: - Input Formatting Tests
    
    func testCardNumberIsFormatted() throws {
        openAddCardSheet()
        
        let cardNumberField = app.textFields[UITestIdentifiers.cardNumberField]
        fillTextField(cardNumberField, with: "4234567890123456")
        
        // Card number should be formatted with spaces
        if let value = cardNumberField.value as? String {
            XCTAssertTrue(value.contains(" "), "Card number should be formatted with spaces")
            XCTAssertEqual(value.count, 19, "Formatted card number should have 19 characters (16 digits + 3 spaces)")
        } else {
            XCTFail("Card number field should have a value")
        }
    }
    
    func testExpiryDateAutoFormats() throws {
        openAddCardSheet()
        
        let expiryField = app.textFields[UITestIdentifiers.expiryDateField]
        fillTextField(expiryField, with: "1228")
        
        // Should auto-format to MM/YY
        if let value = expiryField.value as? String {
            XCTAssertTrue(value.contains("/"), "Expiry date should contain a slash")
            XCTAssertEqual(value, "12/28", "Expiry date should be formatted as MM/YY")
        } else {
            XCTFail("Expiry field should have a value")
        }
    }
    
    func testCVVLimitedToThreeDigits() throws {
        openAddCardSheet()
        
        let cvvField = app.textFields[UITestIdentifiers.cvvField]
        fillTextField(cvvField, with: "12345")
        
        // CVV should be limited to 3 digits
        if let value = cvvField.value as? String {
            XCTAssertLessThanOrEqual(value.count, 3, "CVV should be limited to 3 digits")
        }
    }
    
    func testPINLimitedToFourDigits() throws {
        openAddCardSheet()
        
        let pinField = app.textFields[UITestIdentifiers.pinField]
        fillTextField(pinField, with: "123456")
        
        // PIN should be limited to 4 digits
        if let value = pinField.value as? String {
            XCTAssertLessThanOrEqual(value.count, 4, "PIN should be limited to 4 digits")
        }
    }
}
