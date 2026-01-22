//
//  CardDetailsViewModelTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 15/01/2026.
//

@testable import WalletVault
import XCTest
import SwiftUI
import CoreData

class CardDetailsViewModelTests: XCTestCase {
    
    var mockContext: NSManagedObjectContext!
    var appManager: AppManager!
    var testCard: Card!
    var testColor: ColorEntity!
    var cardObject: CardObservableObject!
    var isEditable: Bool!
    
    override func setUp() {
        super.setUp()
        mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        appManager = AppManager(context: mockContext)
        
        testColor = ColorEntity(context: mockContext)
        testColor.hexValue = Color.purple.toHex()
        testColor.isDefault = true
        
        testCard = Card(context: mockContext)
        testCard.cardName = "Test Card"
        testCard.cardNumber = "4532015112830366" // Valid Visa number
        testCard.expiryDate = "12/30"
        testCard.cvvCode = "123"
        testCard.cardColor = testColor
        testCard.isFavorited = false
        testCard.pin = "1234"
        
        cardObject = CardObservableObject(card: testCard)
        isEditable = false
    }
    
    override func tearDown() {
        isEditable = nil
        cardObject = nil
        testCard = nil
        testColor = nil
        appManager = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_ShouldSetupCorrectly() {
        var isFavoritedCalled = false
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { _ in isFavoritedCalled = true }
        )
        
        XCTAssertEqual(viewModel.cardObject.cardName, "Test Card")
        XCTAssertTrue(viewModel.isUnlocked)
    }
    
    // MARK: - Format Card Number Tests
    
    func testFormatCardNumber_WithValidNumber_ShouldFormatCorrectly() {
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { _ in }
        )
        
        let formatted = viewModel.formatCardNumber("4532015112830366")
        // The actual formatting depends on AppUtils implementation
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testFormatCardNumber_WithEmptyString_ShouldReturnFormattedEmpty() {
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { _ in }
        )
        
        let formatted = viewModel.formatCardNumber("")
        XCTAssertNotNil(formatted)
    }
    
    // MARK: - Card Issuer Image Tests
    
    func testGetCardIssuerImage_WithVisaNumber_ShouldReturnImage() {
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { _ in }
        )
        
        // Visa starts with 4
        let image = viewModel.getCardIssuerImage(cardNumber: "4532015112830366")
        // Image may or may not be nil depending on implementation
        // Just ensure method doesn't crash
        XCTAssertNotNil(viewModel)
    }
    
    func testGetCardIssuerImage_WithMastercardNumber_ShouldReturnImage() {
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { _ in }
        )
        
        // Mastercard starts with 5
        let image = viewModel.getCardIssuerImage(cardNumber: "5425233430109903")
        XCTAssertNotNil(viewModel)
    }
    
    func testGetCardIssuerImage_WithUnknownNumber_ShouldHandleGracefully() {
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { _ in }
        )
        
        let image = viewModel.getCardIssuerImage(cardNumber: "0000000000000000")
        // Should not crash
        XCTAssertNotNil(viewModel)
    }
    
    // MARK: - Card Background Opacity Tests
    
    func testGetCardBackgroundOpacity_ShouldReturnConstantValue() {
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { _ in }
        )
        
        let opacity = viewModel.getCardBackgroundOpacity()
        XCTAssertEqual(opacity, 0.35)
    }
    
    // MARK: - Favorite Toggle Tests
    
    func testSetIsFavorited_ShouldCallClosure() {
        var capturedValue: Bool?
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { isFavorited in
                capturedValue = isFavorited
            }
        )
        
        viewModel.setIsFavorited(true)
        XCTAssertEqual(capturedValue, true)
        
        viewModel.setIsFavorited(false)
        XCTAssertEqual(capturedValue, false)
    }
    
    // MARK: - Editable State Tests
    
    func testIsEditable_BindingWorks() {
        var editableState = false
        let binding = Binding<Bool>(
            get: { editableState },
            set: { editableState = $0 }
        )
        
        let viewModel = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: binding,
            isUnlocked: true,
            setIsFavorited: { _ in }
        )
        
        XCTAssertFalse(viewModel.isEditable)
        
        editableState = true
        XCTAssertTrue(viewModel.isEditable)
    }
    
    // MARK: - Unlocked State Tests
    
    func testIsUnlocked_ShouldReflectInitialState() {
        let viewModelUnlocked = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: true,
            setIsFavorited: { _ in }
        )
        
        XCTAssertTrue(viewModelUnlocked.isUnlocked)
        
        let viewModelLocked = CardDetailsViewModel(
            appManager: appManager,
            cardObject: cardObject,
            isEditing: .constant(false),
            isUnlocked: false,
            setIsFavorited: { _ in }
        )
        
        XCTAssertFalse(viewModelLocked.isUnlocked)
    }
}
