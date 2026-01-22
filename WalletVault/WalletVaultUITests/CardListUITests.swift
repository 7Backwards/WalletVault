//
//  CardListUITests.swift
//  WalletVaultUITests
//
//  Created by Gonçalo on 15/01/2026.
//

import XCTest

final class CardListUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchForUITesting(disableBiometricAuth: true, clearData: true)
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Launch Tests
    
    func testAppLaunchesSuccessfully() throws {
        XCTAssertTrue(app.navigationBars["WalletVault"].exists, "App should launch with WalletVault navigation bar")
    }
    
    // MARK: - Empty State Tests
    
    func testEmptyStateDisplaysWhenNoCards() throws {
        // Since we launch with clearData: true in setUp, it should be empty
        // Use a broader search for the identifier which might be nested or on a container
        let noCardsView = app.descendants(matching: .any)[UITestIdentifiers.noCardsView]
        
        // Try multiple ways to find the empty state if the direct identifier fails
        let exists = waitForElement(noCardsView) || app.staticTexts["No cards yet"].exists
        
        if !exists {
            printHierarchy(in: app)
        }
        
        
        XCTAssertTrue(exists, "Empty state view should be visible when no cards exist")
        
        let titleLabel = app.staticTexts["emptyStateTitle"]
        XCTAssertTrue(titleLabel.exists, "Title text should be visible")
        
        let addLabel = app.staticTexts["emptyStateInstruction"]
        XCTAssertTrue(addLabel.exists, "Instructional text should be visible")
    }
    
    func testAddButtonVisibleInEmptyState() throws {
        let addButton = app.buttons[UITestIdentifiers.addCardButton]
        XCTAssertTrue(waitForElement(addButton), "Add button should be visible in empty state")
        XCTAssertTrue(addButton.isHittable, "Add button should be tappable")
    }
    
    // MARK: - UI Elements Tests
    
    func testSearchBarIsAccessible() throws {
        let searchField = app.textFields[UITestIdentifiers.searchField]
        XCTAssertTrue(searchField.exists, "Search field should exist")
    }
    
    func testQRScannerButtonExists() throws {
        // QR button only exists on iOS, not on macOS
        #if !targetEnvironment(macCatalyst)
        let qrButton = app.buttons[UITestIdentifiers.qrScanButton]
        XCTAssertTrue(qrButton.exists, "QR scanner button should exist on iOS")
        #endif
    }
    
    // MARK: - Navigation Tests
    
    func testTapAddButtonOpensAddCardSheet() throws {
        let addButton = app.buttons[UITestIdentifiers.addCardButton]
        XCTAssertTrue(waitForElement(addButton), "Add button should be visible")
        
        addButton.tap()
        
        // Check that add card view elements appear
        let cardNameField = app.textFields[UITestIdentifiers.cardNameField]
        XCTAssertTrue(waitForElement(cardNameField), "Add card sheet should open and show card name field")
    }
    
    func testAddCardSheetCanBeDismissed() throws {
        let addButton = app.buttons[UITestIdentifiers.addCardButton]
        addButton.tap()
        
        // Wait for sheet to appear
        let cardNameField = app.textFields[UITestIdentifiers.cardNameField]
        XCTAssertTrue(waitForElement(cardNameField), "Add card sheet should be visible")
        
        // Swipe down to dismiss
        swipeDownToDismiss(in: app)
        
        // Verify sheet is dismissed
        XCTAssertTrue(waitForElementToDisappear(cardNameField, timeout: 3), "Add card sheet should be dismissed")
    }
}
