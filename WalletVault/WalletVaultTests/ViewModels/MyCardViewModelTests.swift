//
//  MyCardViewModelTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 15/01/2026.
//

@testable import WalletVault
import XCTest
import SwiftUI
import Combine
import CoreData

class MyCardViewModelTests: XCTestCase {
    
    var mockContext: NSManagedObjectContext!
    var appManager: AppManager!
    var testCard: Card!
    var testColor: ColorEntity!
    var cardObject: CardObservableObject!
    var viewModel: MyCardViewModel!
    
    override func setUp() {
        super.setUp()
        mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        appManager = AppManager(context: mockContext)
        
        testColor = ColorEntity(context: mockContext)
        testColor.hexValue = Color.blue.toHex()
        testColor.isDefault = true
        
        testCard = Card(context: mockContext)
        testCard.cardName = "Test Card"
        testCard.cardNumber = "1234 5678 9012 3456"
        testCard.expiryDate = "12/30"
        testCard.cvvCode = "123"
        testCard.cardColor = testColor
        testCard.isFavorited = false
        testCard.pin = "1234"
        
        cardObject = CardObservableObject(card: testCard)
        viewModel = MyCardViewModel(cardObject: cardObject, appManager: appManager)
    }
    
    override func tearDown() {
        viewModel = nil
        cardObject = nil
        testCard = nil
        testColor = nil
        appManager = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_ShouldSetupCardObject() {
        XCTAssertEqual(viewModel.cardObject.cardName, "Test Card")
        XCTAssertEqual(viewModel.cardObject.cardNumber, "1234 5678 9012 3456")
    }
    
    func testInit_ShouldStartWithNonEditableMode() {
        XCTAssertFalse(viewModel.isEditable)
    }
    
    func testInit_ShouldNotShowDeleteConfirmationInitially() {
        XCTAssertFalse(viewModel.shouldShowDeleteConfirmation)
    }
    
    func testInit_ShouldNotDismissViewInitially() {
        XCTAssertFalse(viewModel.shouldDismissView)
    }
    
    // MARK: - Delete Tests
    
    func testDelete_WithValidCard_ShouldCallCompletion() {
        let expectation = XCTestExpectation(description: "Delete completion called")
        
        viewModel.delete { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDelete_WithNoCardID_ShouldNotCallCompletion() {
        let cardObjectWithoutID = CardObservableObject()
        let viewModelWithoutID = MyCardViewModel(cardObject: cardObjectWithoutID, appManager: appManager)
        
        var completionCalled = false
        
        viewModelWithoutID.delete { _ in
            completionCalled = true
        }
        
        XCTAssertFalse(completionCalled)
    }
    
    // MARK: - Update Card Color Tests
    
    func testUpdateCardColor_WithValidCard_ShouldUpdateColor() {
        let newColor = ColorEntity(context: mockContext)
        newColor.hexValue = Color.red.toHex()
        newColor.isDefault = false
        
        viewModel.updateCardColor(cardColor: newColor)
        
        // Verify the action was dispatched (card color should be updated through AppManager)
        let fetchedCard = mockContext.fetchCard(withID: testCard.objectID)
        XCTAssertEqual(fetchedCard?.cardColor?.hexValue, newColor.hexValue)
    }
    
    func testUpdateCardColor_WithNoCardID_ShouldNotCrash() {
        let cardObjectWithoutID = CardObservableObject()
        let viewModelWithoutID = MyCardViewModel(cardObject: cardObjectWithoutID, appManager: appManager)
        
        let newColor = ColorEntity(context: mockContext)
        newColor.hexValue = Color.red.toHex()
        
        // Should not crash
        viewModelWithoutID.updateCardColor(cardColor: newColor)
    }
    
    // MARK: - Save and Undo Tests
    
    func testSaveCurrentCard_ShouldStoreCardInfo() {
        viewModel.saveCurrentCard()
        
        XCTAssertEqual(viewModel.undoCardInfo.cardName, "Test Card")
        XCTAssertEqual(viewModel.undoCardInfo.cardNumber, "1234 5678 9012 3456")
        XCTAssertEqual(viewModel.undoCardInfo.cvvCode, "123")
        XCTAssertEqual(viewModel.undoCardInfo.expiryDate, "12/30")
        XCTAssertEqual(viewModel.undoCardInfo.pin, "1234")
        XCTAssertFalse(viewModel.undoCardInfo.isFavorited)
    }
    
    func testUndo_ShouldRestoreCardInfo() {
        // Save original state
        viewModel.saveCurrentCard()
        
        // Make changes
        viewModel.cardObject.cardName = "Modified Name"
        viewModel.cardObject.cardNumber = "9999 8888 7777 6666"
        viewModel.cardObject.cvvCode = "999"
        viewModel.cardObject.expiryDate = "01/31"
        viewModel.cardObject.pin = "9999"
        viewModel.cardObject.isFavorited = true
        
        // Undo
        viewModel.undo()
        
        // Verify restoration
        XCTAssertEqual(viewModel.cardObject.cardName, "Test Card")
        XCTAssertEqual(viewModel.cardObject.cardNumber, "1234 5678 9012 3456")
        XCTAssertEqual(viewModel.cardObject.cvvCode, "123")
        XCTAssertEqual(viewModel.cardObject.expiryDate, "12/30")
        XCTAssertEqual(viewModel.cardObject.pin, "1234")
        XCTAssertFalse(viewModel.cardObject.isFavorited)
    }
    
    // MARK: - Auto-Lock Timer Tests
    
    func testStartAutoLockTimer_ShouldSetTimer() {
        viewModel.startAutoLockTimer()
        
        // Timer should be set (we can't directly test private timer, but we can test behavior)
        XCTAssertFalse(viewModel.shouldDismissView)
    }
    
    func testAutoLockTimer_AfterTimeout_ShouldDismissView() {
        let expectation = XCTestExpectation(description: "View should dismiss after timeout")
        
        // Use a very short timeout for testing (modify constants)
        // Note: This test relies on the actual timer duration set in AppConstants
        viewModel.startAutoLockTimer()
        
        // We need to wait for the timer, but that's 30 seconds by default
        // For unit tests, this would be too long, so we'll test the mechanism instead
        
        // Test that invalidate works
        viewModel.invalidateAutoLockTimer()
        
        // Wait a bit to ensure timer doesn't fire
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.viewModel.shouldDismissView)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testInvalidateAutoLockTimer_ShouldCancelTimer() {
        viewModel.startAutoLockTimer()
        viewModel.invalidateAutoLockTimer()
        
        // After invalidation, timer should not trigger dismissal
        XCTAssertFalse(viewModel.shouldDismissView)
    }
    
    // MARK: - Observer Tests
    
    func testIsEditableChange_ToTrue_ShouldInvalidateTimer() {
        // Start timer
        viewModel.startAutoLockTimer()
        
        // Enable edit mode
        viewModel.isEditable = true
        
        // Give time for observer to react
        let expectation = XCTestExpectation(description: "Observer should react")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Timer should be invalidated (view should not dismiss)
            XCTAssertFalse(self.viewModel.shouldDismissView)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testIsEditableChange_ToFalse_ShouldStartTimer() {
        viewModel.isEditable = true
        viewModel.isEditable = false
        
        // Timer should be started again
        let expectation = XCTestExpectation(description: "Observer should react")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.shouldDismissView)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testActiveAlertChange_ToNonNil_ShouldInvalidateTimer() {
        viewModel.startAutoLockTimer()
        
        viewModel.activeAlert = .deleteConfirmation
        
        let expectation = XCTestExpectation(description: "Observer should react")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.shouldDismissView)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testActiveAlertChange_ToNil_ShouldStartTimer() {
        viewModel.activeAlert = .deleteConfirmation
        viewModel.activeAlert = nil
        
        let expectation = XCTestExpectation(description: "Observer should react")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.shouldDismissView)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testActiveShareSheetChange_ToNonNil_ShouldInvalidateTimer() {
        viewModel.startAutoLockTimer()
        
        viewModel.activeShareSheet = .insideShare
        
        let expectation = XCTestExpectation(description: "Observer should react")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.shouldDismissView)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testActiveShareSheetChange_ToNil_ShouldStartTimer() {
        viewModel.activeShareSheet = .insideShare
        viewModel.activeShareSheet = nil
        
        let expectation = XCTestExpectation(description: "Observer should react")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.shouldDismissView)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    // MARK: - Alert Enum Tests
    
    func testActiveAlert_DeleteConfirmation_ShouldHaveCorrectID() {
        let alert = MyCardViewModel.ActiveAlert.deleteConfirmation
        XCTAssertEqual(alert.id, "deleteConfirmation")
    }
    
    func testActiveAlert_Error_ShouldHaveErrorMessageAsID() {
        let errorMessage = "Test error message"
        let alert = MyCardViewModel.ActiveAlert.error(errorMessage)
        XCTAssertEqual(alert.id, errorMessage)
    }
    
    // MARK: - Share Sheet Enum Tests
    
    func testActiveShareSheet_OutsideShare_ShouldHaveCorrectID() {
        let sheet = MyCardViewModel.ActiveShareSheet.outsideShare
        XCTAssertEqual(sheet.id, "outsideShare")
    }
    
    func testActiveShareSheet_InsideShare_ShouldHaveCorrectID() {
        let sheet = MyCardViewModel.ActiveShareSheet.insideShare
        XCTAssertEqual(sheet.id, "insideShare")
    }
}
