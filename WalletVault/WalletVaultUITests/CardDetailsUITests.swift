//
//  CardDetailsUITests.swift
//  WalletVaultUITests
//
//  Created by Gonçalo on 15/01/2026.
//

import XCTest

final class CardDetailsUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchForUITesting(disableBiometricAuth: true, clearData: true)
        
        // Add a card to test details
        addTestCard()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helpers
    
    func addTestCard() {
        let addButton = app.buttons[UITestIdentifiers.addCardButton]
        XCTAssertTrue(waitForElement(addButton), "Add button should be visible")
        addButton.tap()
        
        // Use test data creator
        let card = TestCardData.validCard()
        
        fillTextField(app.textFields[UITestIdentifiers.cardNameField], with: card.name)
        fillTextField(app.textFields[UITestIdentifiers.cardNumberField], with: card.number)
        fillTextField(app.textFields[UITestIdentifiers.expiryDateField], with: card.expiry)
        fillTextField(app.textFields[UITestIdentifiers.cvvField], with: card.cvv)
        if let pin = card.pin {
            fillTextField(app.textFields[UITestIdentifiers.pinField], with: pin)
        }
        
        app.buttons[UITestIdentifiers.saveButton].tap()
        
        let cardNameField = app.textFields[UITestIdentifiers.cardNameField]
        _ = waitForElementToDisappear(cardNameField)
    }
    
    func openFirstCardDetails() {
        // Find the first card button using the identifier prefix
        let cardButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", UITestIdentifiers.cardButtonPrefix))
        
        XCTAssertTrue(cardButtons.count > 0, "At least one card should be present in the list")
        
        let firstCard = cardButtons.element(boundBy: 0)
        XCTAssertTrue(waitForElement(firstCard), "First card button should be visible")
        firstCard.tap()
        
        // Verify we are on details screen
        XCTAssertTrue(waitForElement(app.buttons[UITestIdentifiers.editButton]), "Edit button should be visible on details screen")
    }
    
    // MARK: - View Details Tests
    
    func testCardDetailsAreDisplayed() throws {
        openFirstCardDetails()
        
        // Verify card data is visible (static texts)
        let card = TestCardData.validCard()
        XCTAssertTrue(app.staticTexts[card.name.uppercased()].exists, "Card name should be displayed")
        
        // Number is partially masked or hidden unless revealed, depending on implementation
        // But the last 4 digits should be visible usually
        let lastFour = String(card.number.suffix(4))
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", lastFour)).firstMatch.exists, "Last 4 digits should be visible")
    }
    
    // MARK: - Edit Tests
    
    func testEnterEditMode() throws {
        openFirstCardDetails()
        
        let editButton = app.buttons[UITestIdentifiers.editButton]
        editButton.tap()
        
        // Verify fields become editable text fields
        XCTAssertTrue(app.textFields[UITestIdentifiers.cardNameField].exists, "Name field should be editable")
        XCTAssertTrue(app.textFields[UITestIdentifiers.cardNumberField].exists, "Number field should be editable")
        
        // Verify undo button appears
        XCTAssertTrue(app.buttons[UITestIdentifiers.undoButton].exists, "Undo button should replace edit button")
    }
    
    func testEditAndSaveCard() throws {
        openFirstCardDetails()
        
        // Enter edit mode
        app.buttons[UITestIdentifiers.editButton].tap()
        
        // Wait for edit mode to activate
        let nameField = app.textFields[UITestIdentifiers.cardNameField]
        XCTAssertTrue(waitForElement(nameField, timeout: 2), "Name field should appear in edit mode")
        
        // Change name
        clearAndFillTextField(nameField, with: "UPDATED NAME")
        
        // Wait for save button to appear
        let saveCardButton = app.buttons[UITestIdentifiers.saveButton]
        XCTAssertTrue(waitForElement(saveCardButton, timeout: 2), "Save Card button should be visible in edit mode")
        
        saveCardButton.tap()
        
        // Wait for edit mode to exit
        XCTAssertTrue(waitForElementToDisappear(nameField, timeout: 3), "Should exit edit mode after save")
        
        // Verify updated name is displayed
        XCTAssertTrue(waitForElement(app.staticTexts["UPDATED NAME"], timeout: 2), "Updated name should be displayed")
    }
    
    func testUndoChanges() throws {
        openFirstCardDetails()
        
        // Enter edit mode
        app.buttons[UITestIdentifiers.editButton].tap()
        
        // Change name
        let nameField = app.textFields[UITestIdentifiers.cardNameField]
        clearAndFillTextField(nameField, with: "CHANGED NAME")
        
        // Tap Undo
        app.buttons[UITestIdentifiers.undoButton].tap()
        
        // Verify edit mode exited and name reverted
        XCTAssertFalse(nameField.exists, "Should exit edit mode after undo")
        XCTAssertFalse(app.staticTexts["CHANGED NAME"].exists, "Name should not be updated")
        
        let originalName = TestCardData.validCard().name.uppercased()
        XCTAssertTrue(app.staticTexts[originalName].exists, "Original name should be preserved")
    }
    
    // MARK: - Favorite Tests
    
    func testToggleFavorite() throws {
        openFirstCardDetails()
        
        // The favorite button is a Group with accessibility identifier
        // Try different element types to find it
        let favoriteButton = app.otherElements[UITestIdentifiers.favoriteButton]
        
        if !favoriteButton.exists {
            // If not found as otherElement, try as an image or any element
            let anyFavorite = app.descendants(matching: .any).matching(identifier: UITestIdentifiers.favoriteButton).firstMatch
            XCTAssertTrue(waitForElement(anyFavorite, timeout: 2), "Favorite button should exist")
            anyFavorite.tap()
        } else {
            XCTAssertTrue(waitForElement(favoriteButton, timeout: 2), "Favorite button should exist")
            favoriteButton.tap()
        }
        
        // Verify the tap was successful (no crash)
        XCTAssertTrue(app.buttons[UITestIdentifiers.editButton].exists, "Should still be on details screen")
    }
    
    // MARK: - Delete Tests
    
    func testDeleteCard() throws {
        openFirstCardDetails()
        
        // Tap delete
        let deleteButton = app.buttons[UITestIdentifiers.deleteButton]
        XCTAssertTrue(waitForElement(deleteButton, timeout: 2), "Delete button should exist")
        deleteButton.tap()
        
        // Verify alert appears
        let alert = app.alerts.firstMatch
        XCTAssertTrue(waitForElement(alert, timeout: 3), "Delete confirmation alert should appear")
        
        // Find and tap the destructive/remove button
        // Try common button labels for delete confirmation
        let possibleLabels = ["Remove", "Delete", "Confirm", "Yes"]
        var tapped = false
        
        for label in possibleLabels {
            let button = alert.buttons[label]
            if button.exists {
                button.tap()
                tapped = true
                break
            }
        }
        
        // If no specific button found, try the first button that's not Cancel
        if !tapped {
            for i in 0..<alert.buttons.count {
                let button = alert.buttons.element(boundBy: i)
                if button.label != "Cancel" {
                    button.tap()
                    tapped = true
                    break
                }
            }
        }
        
        XCTAssertTrue(tapped, "Should have tapped a delete confirmation button")
        
        // Wait for alert to disappear
        XCTAssertTrue(waitForElementToDisappear(alert, timeout: 3), "Alert should disappear")
        
        // Should navigate back to list
        let addButton = app.buttons[UITestIdentifiers.addCardButton]
        XCTAssertTrue(waitForElement(addButton, timeout: 5), "Should return to card list")
        
        // Verify empty state (since we had 1 card and deleted it)
        let emptyState = app.otherElements[UITestIdentifiers.noCardsView]
        XCTAssertTrue(waitForElement(emptyState, timeout: 3), "List should show empty state")
    }
}
