//
//  CardRowViewModelTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 15/01/2026.
//

@testable import WalletVault
import XCTest
import SwiftUI
import CoreData

class CardRowViewModelTests: XCTestCase {
    
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
        testColor.hexValue = Color.blue.toHex()
        testColor.isDefault = true
        
        testCard = Card(context: mockContext)
        testCard.cardName = "Row Card"
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
        var activeAlert: CardListViewModel.ActiveAlert? = nil
        let binding = Binding<CardListViewModel.ActiveAlert?>(
            get: { activeAlert },
            set: { activeAlert = $0 }
        )
        
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: binding
        )
        
        XCTAssertEqual(viewModel.cardObject.cardName, "Row Card")
        XCTAssertFalse(viewModel.isEditable)
        XCTAssertNil(activeAlert)
    }
    
    func testInit_ShouldStoreCardObject() {
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: .constant(nil)
        )
        
        XCTAssertEqual(viewModel.cardObject.cardName, "Row Card")
        XCTAssertEqual(viewModel.cardObject.cardNumber, "1234 5678 9012 3456")
        XCTAssertEqual(viewModel.cardObject.cvvCode, "123")
    }
    
    // MARK: - Editable State Tests
    
    func testIsEditable_DefaultsToFalse() {
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: .constant(nil)
        )
        
        XCTAssertFalse(viewModel.isEditable)
    }
    
    func testIsEditable_CanBeToggled() {
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: .constant(nil)
        )
        
        viewModel.isEditable = true
        XCTAssertTrue(viewModel.isEditable)
        
        viewModel.isEditable = false
        XCTAssertFalse(viewModel.isEditable)
    }
    
    // MARK: - Active Alert Binding Tests
    
    func testActiveAlertBinding_ShouldReflectChanges() {
        var activeAlert: CardListViewModel.ActiveAlert? = nil
        let binding = Binding<CardListViewModel.ActiveAlert?>(
            get: { activeAlert },
            set: { activeAlert = $0 }
        )
        
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: binding
        )
        
        XCTAssertNil(activeAlert)
        
        activeAlert = .cardAdded
        XCTAssertEqual(activeAlert?.id, "cardAdded")
        
        activeAlert = .error
        XCTAssertEqual(activeAlert?.id, "error")
    }
    
    func testActiveAlertBinding_WithRemoveCard_ShouldWork() {
        var activeAlert: CardListViewModel.ActiveAlert? = nil
        let binding = Binding<CardListViewModel.ActiveAlert?>(
            get: { activeAlert },
            set: { activeAlert = $0 }
        )
        
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: binding
        )
        
        activeAlert = .removeCard(testCard.objectID)
        XCTAssertEqual(activeAlert?.id, "removeCard")
    }
    
    // MARK: - AppManager Tests
    
    func testAppManager_ShouldBeAccessible() {
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: .constant(nil)
        )
        
        XCTAssertNotNil(viewModel.appManager)
        XCTAssertTrue(viewModel.appManager === appManager)
    }
    
    // MARK: - Card Object Update Tests
    
    func testCardObject_UpdatesShouldReflect() {
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: .constant(nil)
        )
        
        viewModel.cardObject.cardName = "Updated Name"
        XCTAssertEqual(viewModel.cardObject.cardName, "Updated Name")
    }
    
    func testCardObject_MultipleProperties_CanBeUpdated() {
        let viewModel = CardRowViewModel(
            appManager: appManager,
            cardObject: cardObject,
            activeAlert: .constant(nil)
        )
        
        viewModel.cardObject.cardName = "New Name"
        viewModel.cardObject.isFavorited = true
        
        XCTAssertEqual(viewModel.cardObject.cardName, "New Name")
        XCTAssertTrue(viewModel.cardObject.isFavorited)
    }
}
