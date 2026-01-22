//
//  AddCardViewModelTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 15/01/2026.
//

@testable import WalletVault
import XCTest
import SwiftUI
import CoreData

class AddCardViewModelTests: XCTestCase {
    
    var mockContext: NSManagedObjectContext!
    var appManager: AppManager!
    var viewModel: AddCardViewModel!
    var testColor: ColorEntity!
    
    override func setUp() {
        super.setUp()
        mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        appManager = AppManager(context: mockContext)
        viewModel = AddCardViewModel(appManager: appManager)
        
        testColor = ColorEntity(context: mockContext)
        testColor.hexValue = Color.green.toHex()
        testColor.isDefault = true
    }
    
    override func tearDown() {
        viewModel = nil
        testColor = nil
        appManager = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_ShouldStartWithEmptyCardObject() {
        XCTAssertEqual(viewModel.cardObject.cardName, "")
        XCTAssertEqual(viewModel.cardObject.cardNumber, "")
        XCTAssertEqual(viewModel.cardObject.expiryDate, "")
        XCTAssertEqual(viewModel.cardObject.cvvCode, "")
        XCTAssertNil(viewModel.cardObject.cardColor)
        XCTAssertFalse(viewModel.cardObject.isFavorited)
        XCTAssertEqual(viewModel.cardObject.pin, "")
    }
    
    func testInit_ShouldStartInEditableMode() {
        XCTAssertTrue(viewModel.isEditable)
    }
    
    func testInit_ShouldHaveNoSelectedColorInitially() {
        XCTAssertNil(viewModel.selectedColor)
    }
    
    func testInit_ShouldHaveNoActiveAlertInitially() {
        XCTAssertNil(viewModel.activeAlert)
    }
    
    // MARK: - Selected Color Tests
    
    func testSelectedColor_CanBeSet() {
        viewModel.selectedColor = testColor
        XCTAssertEqual(viewModel.selectedColor?.hexValue, testColor.hexValue)
    }
    
    func testSelectedColor_CanBeCleared() {
        viewModel.selectedColor = testColor
        viewModel.selectedColor = nil
        XCTAssertNil(viewModel.selectedColor)
    }
    
    // MARK: - Card Object Tests
    
    func testCardObject_CanBeUpdated() {
        viewModel.cardObject.cardName = "New Card"
        viewModel.cardObject.cardNumber = "1234 5678 9012 3456"
        viewModel.cardObject.expiryDate = "12/30"
        viewModel.cardObject.cvvCode = "123"
        viewModel.cardObject.cardColor = testColor
        viewModel.cardObject.pin = "1234"
        
        XCTAssertEqual(viewModel.cardObject.cardName, "New Card")
        XCTAssertEqual(viewModel.cardObject.cardNumber, "1234 5678 9012 3456")
        XCTAssertEqual(viewModel.cardObject.expiryDate, "12/30")
        XCTAssertEqual(viewModel.cardObject.cvvCode, "123")
        XCTAssertEqual(viewModel.cardObject.cardColor?.hexValue, testColor.hexValue)
        XCTAssertEqual(viewModel.cardObject.pin, "1234")
    }
    
    func testCardObject_FavoritedCanBeToggled() {
        viewModel.cardObject.isFavorited = true
        XCTAssertTrue(viewModel.cardObject.isFavorited)
        
        viewModel.cardObject.isFavorited = false
        XCTAssertFalse(viewModel.cardObject.isFavorited)
    }
    
    // MARK: - Integration with AddOrEditMyCardViewModel Tests
    
    func testAddCard_WithValidData_ShouldSucceed() {
        viewModel.cardObject.cardName = "Test Card"
        viewModel.cardObject.cardNumber = "1234 5678 9012 3456"
        viewModel.cardObject.expiryDate = "12/30"
        viewModel.cardObject.cvvCode = "123"
        viewModel.cardObject.cardColor = testColor
        viewModel.cardObject.pin = "1234"
        
        let expectation = XCTestExpectation(description: "Add card should succeed")
        
        viewModel.addOrEdit(cardObject: viewModel.cardObject) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Active Alert Enum Tests
    
    func testActiveAlert_DeleteConfirmation_ShouldHaveCorrectID() {
        let alert = AddCardViewModel.ActiveAlert.deleteConfirmation
        XCTAssertEqual(alert.id, "deleteConfirmation")
    }
    
    func testActiveAlert_Error_ShouldHaveErrorMessageAsID() {
        let errorMessage = "Test error"
        let alert = AddCardViewModel.ActiveAlert.error(errorMessage)
        XCTAssertEqual(alert.id, errorMessage)
    }
    
    func testActiveAlert_CanBeSet() {
        viewModel.activeAlert = .deleteConfirmation
        XCTAssertEqual(viewModel.activeAlert?.id, "deleteConfirmation")
        
        viewModel.activeAlert = .error("Test")
        XCTAssertEqual(viewModel.activeAlert?.id, "Test")
    }
    
    // MARK: - Editable State Tests
    
    func testIsEditable_CanBeToggled() {
        viewModel.isEditable = false
        XCTAssertFalse(viewModel.isEditable)
        
        viewModel.isEditable = true
        XCTAssertTrue(viewModel.isEditable)
    }
}
