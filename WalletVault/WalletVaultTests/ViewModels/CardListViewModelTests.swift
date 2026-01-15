//
//  CardListViewModelTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 15/01/2026.
//

@testable import WalletVault
import XCTest
import SwiftUI
import CoreData

class CardListViewModelTests: XCTestCase {
    
    var mockContext: NSManagedObjectContext!
    var appManager: AppManager!
    var viewModel: CardListViewModel!
    var testColor: ColorEntity!
    
    override func setUp() {
        super.setUp()
        mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        appManager = AppManager(context: mockContext)
        viewModel = CardListViewModel(appManager: appManager)
        
        testColor = ColorEntity(context: mockContext)
        testColor.hexValue = Color.black.toHex()
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
    
    func testInit_ShouldStartWithEmptySearchText() {
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    func testInit_ShouldNotShowErrorMessageInitially() {
        XCTAssertFalse(viewModel.isShowingErrorMessage)
    }
    
    func testInit_ShouldHaveNoActiveAlertsInitially() {
        XCTAssertNil(viewModel.activeAlert)
    }
    
    func testInit_ShouldHaveNoActiveSheetsInitially() {
        XCTAssertNil(viewModel.activeShareSheet)
    }
    
    // MARK: - Search Functionality Tests
    
    func testSearchText_CanBeUpdated() {
        viewModel.searchText = "Visa"
        XCTAssertEqual(viewModel.searchText, "Visa")
    }
    
    func testSearchText_CanBeCleared() {
        viewModel.searchText = "Test"
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    // MARK: - Camera Permission Tests
    
    func testRequestCameraPermission_ShouldCallCompletion() {
        let expectation = XCTestExpectation(description: "Camera permission completion called")
        
        viewModel.requestCameraPermission { granted in
            // Completion is called regardless of permission status
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Delete Card Tests
    
    func testDeleteCard_ShouldRemoveCardFromContext() {
        // Create a test card
        let card = Card(context: mockContext)
        card.cardName = "Test Card"
        card.cardNumber = "1234 5678 9012 3456"
        card.expiryDate = "12/30"
        card.cvvCode = "123"
        card.cardColor = testColor
        card.pin = "1234"
        
        try? mockContext.save()
        
        let cardID = card.objectID
        
        // Create mock FetchedResults (we'll simulate the deletion)
        // Note: We can't easily create FetchedResults in tests, so we'll just test the method exists
        // and the action is dispatched
        
        // The method doesn't return anything, but it should trigger the action
        // We can verify the card is deleted through the context
        appManager.actionManager.doAction(action: .removeCard(cardID))
        
        // Verify card is deleted
        let fetchedCard = mockContext.fetchCard(withID: cardID)
        XCTAssertNil(fetchedCard)
    }
    
    // MARK: - Authentication Tests
    
    func testAuthenticate_WithMockBiometric_ShouldCallCompletion() {
        let expectation = XCTestExpectation(description: "Authentication completion called")
        
        viewModel.authenticate { result in
            // Completion is called
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - CardObservableObject Caching Tests
    
    func testGetCardObservableObject_WithNewCard_ShouldCreateNewViewModel() {
        let card = Card(context: mockContext)
        card.cardName = "Test Card"
        card.cardNumber = "1234 5678 9012 3456"
        card.expiryDate = "12/30"
        card.cvvCode = "123"
        card.cardColor = testColor
        card.pin = "1234"
        
        let cardViewModel = viewModel.getCardObservableObject(for: card)
        
        XCTAssertEqual(cardViewModel.cardName, "Test Card")
        XCTAssertEqual(cardViewModel.cardNumber, "1234 5678 9012 3456")
    }
    
    func testGetCardObservableObject_WithSameCard_ShouldReturnCachedViewModel() {
        let card = Card(context: mockContext)
        card.cardName = "Test Card"
        card.cardNumber = "1234 5678 9012 3456"
        card.expiryDate = "12/30"
        card.cvvCode = "123"
        card.cardColor = testColor
        card.pin = "1234"
        
        let cardViewModel1 = viewModel.getCardObservableObject(for: card)
        let cardViewModel2 = viewModel.getCardObservableObject(for: card)
        
        // Should return the same instance
        XCTAssertTrue(cardViewModel1 === cardViewModel2)
    }
    
    func testGetCardObservableObject_WithDifferentCards_ShouldReturnDifferentViewModels() {
        let card1 = Card(context: mockContext)
        card1.cardName = "Card 1"
        card1.cardNumber = "1234 5678 9012 3456"
        card1.expiryDate = "12/30"
        card1.cvvCode = "123"
        card1.cardColor = testColor
        card1.pin = "1234"
        
        let card2 = Card(context: mockContext)
        card2.cardName = "Card 2"
        card2.cardNumber = "9876 5432 1098 7654"
        card2.expiryDate = "06/31"
        card2.cvvCode = "456"
        card2.cardColor = testColor
        card2.pin = "5678"
        
        let cardViewModel1 = viewModel.getCardObservableObject(for: card1)
        let cardViewModel2 = viewModel.getCardObservableObject(for: card2)
        
        XCTAssertTrue(cardViewModel1 !== cardViewModel2)
        XCTAssertEqual(cardViewModel1.cardName, "Card 1")
        XCTAssertEqual(cardViewModel2.cardName, "Card 2")
    }
    
    // MARK: - ActiveShareSheet Enum Tests
    
    func testActiveShareSheet_AddCard_ShouldHaveCorrectID() {
        let sheet = CardListViewModel.ActiveShareSheet.addCard
        XCTAssertEqual(sheet.id, "addCard")
    }
    
    func testActiveShareSheet_ScanQRCode_ShouldHaveCorrectID() {
        let sheet = CardListViewModel.ActiveShareSheet.scanQRCode
        XCTAssertEqual(sheet.id, "scanQRCode")
    }
    
    func testActiveShareSheet_CanBeSet() {
        viewModel.activeShareSheet = .addCard
        XCTAssertEqual(viewModel.activeShareSheet?.id, "addCard")
        
        viewModel.activeShareSheet = .scanQRCode
        XCTAssertEqual(viewModel.activeShareSheet?.id, "scanQRCode")
    }
    
    // MARK: - ActiveAlert Enum Tests
    
    func testActiveAlert_CardAdded_ShouldHaveCorrectID() {
        let alert = CardListViewModel.ActiveAlert.cardAdded
        XCTAssertEqual(alert.id, "cardAdded")
    }
    
    func testActiveAlert_Error_ShouldHaveCorrectID() {
        let alert = CardListViewModel.ActiveAlert.error
        XCTAssertEqual(alert.id, "error")
    }
    
    func testActiveAlert_RemoveCard_ShouldHaveCorrectID() {
        let card = Card(context: mockContext)
        card.cardName = "Test"
        card.cardNumber = "1234 5678 9012 3456"
        card.expiryDate = "12/30"
        card.cvvCode = "123"
        card.cardColor = testColor
        card.pin = "1234"
        
        let alert = CardListViewModel.ActiveAlert.removeCard(card.objectID)
        XCTAssertEqual(alert.id, "removeCard")
    }
    
    func testActiveAlert_RequestCameraPermission_ShouldHaveCorrectID() {
        let alert = CardListViewModel.ActiveAlert.requestCameraPermission
        XCTAssertEqual(alert.id, "requestCameraPermission")
    }
    
    func testActiveAlert_CanBeSet() {
        viewModel.activeAlert = .cardAdded
        XCTAssertEqual(viewModel.activeAlert?.id, "cardAdded")
        
        viewModel.activeAlert = .error
        XCTAssertEqual(viewModel.activeAlert?.id, "error")
        
        viewModel.activeAlert = .requestCameraPermission
        XCTAssertEqual(viewModel.activeAlert?.id, "requestCameraPermission")
    }
    
    // MARK: - Error Message Tests
    
    func testIsShowingErrorMessage_CanBeToggled() {
        viewModel.isShowingErrorMessage = true
        XCTAssertTrue(viewModel.isShowingErrorMessage)
        
        viewModel.isShowingErrorMessage = false
        XCTAssertFalse(viewModel.isShowingErrorMessage)
    }
}
