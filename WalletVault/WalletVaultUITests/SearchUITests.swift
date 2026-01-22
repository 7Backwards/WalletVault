//
//  SearchUITests.swift
//  WalletVaultUITests
//
//  Created by Gonçalo on 15/01/2026.
//

import XCTest

final class SearchUITests: XCTestCase {
    var app: XCUIApplication!
    private static var hasSeedData = false

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Only clear data on the first test of this suite
        let shouldClear = !Self.hasSeedData
        app.launchForUITesting(disableBiometricAuth: true, clearData: shouldClear)
        
        // Add test cards only once
        if !Self.hasSeedData {
            addTestCards()
            Self.hasSeedData = true
        }
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    func addTestCards() {
        let cards = TestCardData.multipleCards(count: 3)
        
        for card in cards {
            logAlerts(in: app)
            let addButton = app.buttons[UITestIdentifiers.addCardButton]
            XCTAssertTrue(waitForElement(addButton, timeout: 10), "Add button should exist")
            addButton.tap()
            
            fillTextField(app.textFields[UITestIdentifiers.cardNameField], with: card.name)
            fillTextField(app.textFields[UITestIdentifiers.cardNumberField], with: card.number)
            fillTextField(app.textFields[UITestIdentifiers.expiryDateField], with: card.expiry)
            fillTextField(app.textFields[UITestIdentifiers.cvvField], with: card.cvv)
            
            // Dismiss keyboard to ensure save button is hittable and formatters have completed
            dismissKeyboard(in: app)
            
            // Extra wait to ensure all onChange formatters have completed
            usleep(500_000) // 0.5 seconds
            
            let saveButton = app.buttons[UITestIdentifiers.saveButton]
            XCTAssertTrue(waitForElement(saveButton, timeout: 5), "Save button should exist")
            saveButton.tap()
            
            // Check for error alert
            if app.alerts.count > 0 {
                logAlerts(in: app)
                app.alerts.buttons.firstMatch.tap() // Dismiss it to let other tests proceed if possible
                XCTFail("Error alert appeared while adding test cards")
            }
            
            // Wait for sheet to dismiss
            let cardNameField = app.textFields[UITestIdentifiers.cardNameField]
            _ = waitForElementToDisappear(cardNameField, timeout: 10)
            
            // Wait for UI to settle before next card
            usleep(500_000) // 0.5 seconds
        }
    }
    
    // MARK: - Search Field Tests
    
    func testSearchFieldIsAccessible() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        XCTAssertTrue(searchField.isEnabled, "Search field should be enabled")
    }
    
    func testSearchFieldAcceptsInput() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        fillTextField(searchField, with: "Visa")
        
        XCTAssertEqual(searchField.value as? String, "Visa", "Search field should contain typed text")
    }
    
    // MARK: - Search Functionality Tests
    
    func testSearchByCardName() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        fillTextField(searchField, with: "Personal")
        
        // Give time for filter to apply
        sleep(1)
        
        // Verify filtered results (Personal Visa should be visible)
        XCTAssertTrue(app.staticTexts["PERSONAL VISA"].exists, "Card matching search should be visible")
    }
    
    func testSearchByCardNumber() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        searchField.tap()
        searchField.typeText("4234")
        
        sleep(1)
        
        // At least one card with matching number should be visible
        // Verify filtered results (Personal Visa matches 4234)
        XCTAssertTrue(app.staticTexts["PERSONAL VISA"].exists, "Card matching number search should be visible")
    }
    
    func testSearchIsCaseInsensitive() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        
        // Search with lowercase
        searchField.tap()
        searchField.typeText("personal")
        
        sleep(1)
        
        // Should still find "Personal Visa" (case-insensitive)
        XCTAssertTrue(app.staticTexts["PERSONAL VISA"].exists, "Search should be case-insensitive")
    }
    
    func testClearSearchShowsAllCards() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        
        // First, search for something specific
        fillTextField(searchField, with: "Personal")
        
        sleep(1)
        
        // Clear the search
        let clearButton = searchField.buttons["Clear text"].firstMatch
        if clearButton.exists {
            clearButton.tap()
        } else {
            // Alternative: select all and delete
            searchField.tap()
            searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 10))
        }
        
        sleep(1)
        
        // All cards should be visible again
        let noSearchResults = app.otherElements[UITestIdentifiers.noSearchResultsView]
        XCTAssertFalse(noSearchResults.exists, "No search results view should not appear when search is cleared")
    }
    
    func testNoResultsStateDisplayed() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        searchField.tap()
        searchField.typeText("NonExistentCard123")
        
        sleep(1)
        
        // No results view should appear
        let noSearchResults = app.descendants(matching: .any)[UITestIdentifiers.noSearchResultsView]
        XCTAssertTrue(waitForElement(noSearchResults, timeout: 5), "No search results view should appear")
        XCTAssertTrue(app.staticTexts["No cards found"].exists, "No results message should be displayed")
    }
    
    func testNoResultsMessageGuidance() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        fillTextField(searchField, with: "XYZ")
        
        sleep(1)
        
        let noSearchResults = app.descendants(matching: .any)[UITestIdentifiers.noSearchResultsView]
        let exists = waitForElement(noSearchResults)
        
        if !exists {
            printHierarchy(in: app)
        }
        
        XCTAssertTrue(exists, "No results view should appear")
        XCTAssertTrue(app.staticTexts["Try a different search term"].exists, "Guidance message should be shown")
    }
    
    // MARK: - Keyboard Interaction Tests
    
    func testKeyboardDismissesOnTapOutside() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        searchField.tap()
        
        // Keyboard should be visible
        XCTAssertTrue(app.keyboards.count > 0, "Keyboard should be visible")
        
        // Tap on the background area using coordinates to avoid AX errors with ScrollView
        // Tap the center of the screen which should be the content area
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        
        // Keyboard should dismiss
        sleep(1)
        if app.keyboards.count > 0 {
            printHierarchy(in: app)
        }
        XCTAssertTrue(app.keyboards.count == 0, "Keyboard should be dismissed")
    }
}
