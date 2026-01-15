//
//  UITestHelpers.swift
//  WalletVaultUITests
//
//  Created by Gonçalo on 15/01/2026.
//

import XCTest

extension XCUIApplication {
    /// Launch app with UI testing configuration
    func launchForUITesting(disableBiometricAuth: Bool = true, clearData: Bool = true) {
        launchArguments = ["UI-TESTING"]
        
        if disableBiometricAuth {
            launchArguments.append("DISABLE-BIOMETRIC-AUTH")
        }
        
        if clearData {
            launchArguments.append("CLEAR-DATA")
        }
        
        launch()
    }
}

extension XCTestCase {
    /// Wait for element to appear with timeout
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Wait for element to disappear with timeout
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Dismiss keyboard
    func dismissKeyboard(in app: XCUIApplication) {
        if app.keyboards.count > 0 {
            // Try tapping "Done" or "Return" if available
            let returnButton = app.keyboards.buttons["Return"]
            if returnButton.exists && returnButton.isHittable {
                returnButton.tap()
            } else {
                // Otherwise tap outside
                app.tap()
            }
        }
    }
    
    /// Tap element if it exists and is hittable
    func tapIfExists(_ element: XCUIElement, timeout: TimeInterval = 2) -> Bool {
        guard waitForElement(element, timeout: timeout), element.isHittable else {
            return false
        }
        element.tap()
        return true
    }
    
    /// Fill text field with value
    func fillTextField(_ element: XCUIElement, with text: String, app: XCUIApplication? = nil) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Text field should exist: \(element.description)")
        
        // Tap and wait for keyboard focus
        if !element.hasFocus {
            element.tap()
            // Wait a small amount for the keyboard and focus
            sleep(1)
        }
        
        // Type the text character by character with a small delay for formatters
        for char in text {
            element.typeText(String(char))
            usleep(30_000) // 0.03 seconds between characters
        }
        
        // Wait for onChange formatters to complete (critical for card number formatting)
        usleep(300_000) // 0.3 seconds after typing is finished
    }
    
    /// Clear and fill text field with value
    func clearAndFillTextField(_ element: XCUIElement, with text: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Text field should exist")
        element.tap()
        
        // Clear existing text if any
        if let currentValue = element.value as? String, !currentValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            element.typeText(deleteString)
        }
        
        // Type the text character by character with a small delay for formatters
        for char in text {
            element.typeText(String(char))
            usleep(30_000) // 0.03 seconds between characters
        }
        usleep(300_000)
    }
    
    /// Log any visible alerts
    func logAlerts(in app: XCUIApplication) {
        let alerts = app.alerts
        if alerts.count > 0 {
            for i in 0..<alerts.count {
                let alert = alerts.element(boundBy: i)
                print("DEBUG: Alert \(i) - Title: \(alert.label)")
                
                // Log all static texts in the alert
                let staticTexts = alert.staticTexts
                for j in 0..<staticTexts.count {
                    let text = staticTexts.element(boundBy: j)
                    print("DEBUG: Alert \(i) - Text[\(j)]: \(text.label)")
                }
            }
        } else {
            print("DEBUG: No alerts visible")
        }
    }
    
    /// Swipe down from the top to dismiss a sheet
    func swipeDownToDismiss(in app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)
    }
    /// Prints the entire app hierarchy for debugging
    func printHierarchy(in app: XCUIApplication) {
        print("DEBUG: App Hierarchy:\n\(app.debugDescription)")
    }
    
    /// Open the first card in the list
    func openFirstCardDetails(in app: XCUIApplication) {
        // Find the first card button using the identifier prefix
        let cardButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", UITestIdentifiers.cardButtonPrefix))
        
        // Wait for at least one card to appear
        let firstCard = cardButtons.firstMatch
        XCTAssertTrue(waitForElement(firstCard), "At least one card should be present in the list")
        
        firstCard.tap()
        
        // Verify we are on details screen
        // Use a timeout to allow for navigation animation
        XCTAssertTrue(waitForElement(app.buttons[UITestIdentifiers.editButton]), "Edit button should be visible on details screen")
    }

    /// Basic wait for safety
    func XCWait(_ duration: TimeInterval) {
        let expectation = XCTestExpectation(description: "Wait for \(duration) seconds")
        XCTWaiter().wait(for: [expectation], timeout: duration)
    }
}

extension XCUIElement {
    var hasFocus: Bool {
        return (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
    }
}

/// UI Element Identifiers
struct UITestIdentifiers {
    // Card List
    static let searchField = "searchField"
    static let addCardButton = "addCardButton"
    static let qrScanButton = "qrScanButton"
    static let noCardsView = "noCardsView"
    static let noSearchResultsView = "noSearchResultsView"
    static let cardButtonPrefix = "cardButton_"
    
    // Add/Edit Card
    static let cardNameField = "cardNameField"
    static let cardNumberField = "cardNumberField"
    static let expiryDateField = "expiryDateField"
    static let cvvField = "cvvField"
    static let pinField = "pinField"
    static let saveButton = "saveButton"
    static let addButton = "addButton"
    
    // Card Details
    static let editButton = "editButton"
    static let deleteButton = "deleteButton"
    static let shareButton = "shareButton"
    static let undoButton = "undoButton"
    static let favoriteButton = "favoriteButton"
    
    // Color Picker
    static let colorCarousel = "colorCarousel"
    static let customColorButton = "customColorButton"
    static let customColorPicker = "customColorPicker"
    
    // Share Sheet
    static let qrCodeImage = "qrCodeImage"
    static let shareCodeText = "shareCodeText"
    static let copyCodeButton = "copyCodeButton"
    
    // Alerts
    static let deleteConfirmButton = "deleteConfirmButton"
    static let cancelButton = "cancelButton"
}
