//
//  AddCardButtonViewModelTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 15/01/2026.
//

@testable import WalletVault
import XCTest
import SwiftUI
import CoreData

class AddCardButtonViewModelTests: XCTestCase {
    
    var mockContext: NSManagedObjectContext!
    var appManager: AppManager!
    var testCard: Card!
    var testColor: ColorEntity!
    var cardObject: CardObservableObject!
    
    override func setUp() {
        super.setUp()
        mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        appManager = AppManager(context: mockContext)
        
        testColor = ColorEntity(context: mockContext)
        testColor.hexValue = Color.green.toHex()
        testColor.isDefault = true
        
        testCard = Card(context: mockContext)
        testCard.cardName = "Button Card"
        testCard.cardNumber = "1234 5678 9012 3456"
        testCard.expiryDate = "12/30"
        testCard.cvvCode = "123"
        testCard.cardColor = testColor
        testCard.pin = "1234"
        
        cardObject = CardObservableObject(card: testCard)
    }
    
    override func tearDown() {
        cardObject = nil
        testCard = nil
        testColor = nil
        appManager = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_ShouldSetupCorrectly() {
        var isEditable = false
        var alertMessage: String?
        
        let editableBinding = Binding<Bool>(
            get: { isEditable },
            set: { isEditable = $0 }
        )
        
        let viewModel = AddCardButtonViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditable: editableBinding,
            showAlert: { message in
                alertMessage = message
            }
        )
        
        XCTAssertEqual(viewModel.cardObject.cardName, "Button Card")
        XCTAssertFalse(isEditable)
        XCTAssertNil(alertMessage)
    }
    
    // MARK: - Editable Binding Tests
    
    func testIsEditableBinding_ShouldReflectChanges() {
        var isEditable = false
        let editableBinding = Binding<Bool>(
            get: { isEditable },
            set: { isEditable = $0 }
        )
        
        let viewModel = AddCardButtonViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditable: editableBinding,
            showAlert: { _ in }
        )
        
        XCTAssertFalse(viewModel.isEditable)
        
        isEditable = true
        XCTAssertTrue(viewModel.isEditable)
        
        isEditable = false
        XCTAssertFalse(viewModel.isEditable)
    }
    
    // MARK: - Show Alert Closure Tests
    
    func testShowAlert_ShouldCallClosure() {
        var capturedMessage: String?
        
        let viewModel = AddCardButtonViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditable: .constant(false),
            showAlert: { message in
                capturedMessage = message
            }
        )
        
        viewModel.showAlert("Test error message")
        XCTAssertEqual(capturedMessage, "Test error message")
    }
    
    func testShowAlert_WithMultipleMessages_ShouldCaptureAll() {
        var capturedMessages: [String] = []
        
        let viewModel = AddCardButtonViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditable: .constant(false),
            showAlert: { message in
                capturedMessages.append(message)
            }
        )
        
        viewModel.showAlert("Error 1")
        viewModel.showAlert("Error 2")
        viewModel.showAlert("Error 3")
        
        XCTAssertEqual(capturedMessages.count, 3)
        XCTAssertEqual(capturedMessages[0], "Error 1")
        XCTAssertEqual(capturedMessages[1], "Error 2")
        XCTAssertEqual(capturedMessages[2], "Error 3")
    }
    
    // MARK: - Card Object Tests
    
    func testCardObject_ShouldBeAccessible() {
        let viewModel = AddCardButtonViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditable: .constant(false),
            showAlert: { _ in }
        )
        
        XCTAssertEqual(viewModel.cardObject.cardName, "Button Card")
        XCTAssertEqual(viewModel.cardObject.cardNumber, "1234 5678 9012 3456")
    }
    
    func testCardObject_UpdatesShouldReflect() {
        let viewModel = AddCardButtonViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditable: .constant(false),
            showAlert: { _ in }
        )
        
        viewModel.cardObject.cardName = "Modified Card"
        XCTAssertEqual(viewModel.cardObject.cardName, "Modified Card")
    }
    
    // MARK: - Integration with AddOrEditMyCardViewModel Tests
    
    func testAddOrEdit_ShouldInheritFromBaseClass() {
        let viewModel = AddCardButtonViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditable: .constant(false),
            showAlert: { _ in }
        )
        
        // Verify it can call the inherited method
        viewModel.cardObject.cardNumber = "1234 5678 9012 3456"
        viewModel.cardObject.expiryDate = "12/30"
        viewModel.cardObject.cvvCode = "123"
        viewModel.cardObject.cardColor = testColor
        viewModel.cardObject.pin = "1234"
        
        let expectation = XCTestExpectation(description: "AddOrEdit should work")
        
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
    
    // MARK: - AppManager Tests
    
    func testAppManager_ShouldBeAccessible() {
        let viewModel = AddCardButtonViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditable: .constant(false),
            showAlert: { _ in }
        )
        
        XCTAssertNotNil(viewModel.appManager)
        XCTAssertTrue(viewModel.appManager === appManager)
    }
}
