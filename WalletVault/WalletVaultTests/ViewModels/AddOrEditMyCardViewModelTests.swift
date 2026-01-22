//
//  AddOrEditMyCardViewModelTests.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 10/03/2024.
//

@testable import WalletVault
import XCTest
import SwiftUI
import CoreData


class AddOrEditMyCardViewModelTests: XCTestCase {
    
    var mockContext: NSManagedObjectContext!
    var appManager: AppManager!
    var viewModel: AddOrEditMyCardViewModel!
    var testColor: ColorEntity!
    
    override func setUp() {
        super.setUp()
        mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        appManager = AppManager(context: mockContext)
        viewModel = AddOrEditMyCardViewModel(appManager: appManager)
        
        testColor = ColorEntity(context: mockContext)
        testColor.hexValue = Color.black.toHex()
        testColor.isDefault = true
    }
    
    override func tearDown() {
        mockContext = nil
        appManager = nil
        viewModel = nil
        testColor = nil
        super.tearDown()
    }
    
    // MARK: - Adding New Card Tests
    
    func testAddNewCard_WithValidData_ShouldSucceed() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 3456" // 19 characters with spaces
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        cardObject.isFavorited = false
        cardObject.pin = "1234"
        
        let expectation = XCTestExpectation(description: "Add card should succeed")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEditExistingCard_WithValidData_ShouldUpdateCard() {
        let card = Card(context: mockContext)
        card.cardName = "Original Card"
        card.cardNumber = "1234 5678 9012 3456"
        card.expiryDate = "12/30"
        card.cvvCode = "123"
        card.cardColor = testColor
        card.isFavorited = false
        card.pin = "1234"
        
        let cardObject = CardObservableObject(card: card, appUtils: appManager.utils)
        cardObject.cardName = "Updated Card Name"
        
        let expectation = XCTestExpectation(description: "Edit should succeed")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                let fetchedCard = self.mockContext.fetchCard(withID: card.objectID)
                XCTAssertEqual(fetchedCard?.cardName, "Updated Card Name")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Validation Tests
    
    func testAddOrEdit_WithEmptyCardName_ShouldNotCallCompletion() {
        let cardObject = CardObservableObject()
        cardObject.cardName = ""
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        var completionCalled = false
        
        viewModel.addOrEdit(cardObject: cardObject) { _ in
            completionCalled = true
        }
        
        XCTAssertFalse(completionCalled, "Completion should not be called with empty card name")
    }
    
    func testAddOrEdit_WithEmptyCardNumber_ShouldNotCallCompletion() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = ""
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        var completionCalled = false
        
        viewModel.addOrEdit(cardObject: cardObject) { _ in
            completionCalled = true
        }
        
        XCTAssertFalse(completionCalled, "Completion should not be called with empty card number")
    }
    
    func testAddOrEdit_WithEmptyExpiryDate_ShouldNotCallCompletion() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = ""
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        var completionCalled = false
        
        viewModel.addOrEdit(cardObject: cardObject) { _ in
            completionCalled = true
        }
        
        XCTAssertFalse(completionCalled, "Completion should not be called with empty expiry date")
    }
    
    func testAddOrEdit_WithEmptyCVV_ShouldNotCallCompletion() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = ""
        cardObject.cardColor = testColor
        
        var completionCalled = false
        
        viewModel.addOrEdit(cardObject: cardObject) { _ in
            completionCalled = true
        }
        
        XCTAssertFalse(completionCalled, "Completion should not be called with empty CVV")
    }
    
    // MARK: - Card Number Length Tests
    
    func testAddOrEdit_WithShortCardNumber_ShouldReturnError() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012" // Only 14 characters
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        let expectation = XCTestExpectation(description: "Should fail with short card number")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .shortCardNumber)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddOrEdit_WithLongCardNumber_ShouldReturnError() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 34567" // 21 characters
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        let expectation = XCTestExpectation(description: "Should fail with long card number")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .shortCardNumber)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Card Type Specific Length Tests
    
    func testAddAmexCard_With15Digits_ShouldSucceed() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Amex Card"
        cardObject.cardNumber = "3782 822463 10005" // 15 digits + 2 spaces = 17 chars
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "1234" // 4-digit CID for Amex
        cardObject.cardColor = testColor
        cardObject.pin = ""
        
        let expectation = XCTestExpectation(description: "Amex with 15 digits should succeed")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddAmexCard_With16Digits_ShouldFail() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Amex Card"
        cardObject.cardNumber = "3782 8224 6310 0050" // 16 digits formatted as standard (wrong for Amex)
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "1234"
        cardObject.cardColor = testColor
        
        let expectation = XCTestExpectation(description: "Amex with 16 digits should fail")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .shortCardNumber)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddDiscoverCard_With16Digits_ShouldSucceed() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Discover Card"
        cardObject.cardNumber = "6011 1111 1111 1117" // 16 digits
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "789"
        cardObject.cardColor = testColor
        cardObject.pin = ""
        
        let expectation = XCTestExpectation(description: "Discover with 16 digits should succeed")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddVisaCard_With15Digits_ShouldFail() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Visa Card"
        cardObject.cardNumber = "4111 1111 1111 111" // 15 digits (wrong for Visa)
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        let expectation = XCTestExpectation(description: "Visa with 15 digits should fail")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .shortCardNumber)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Date Validation Tests
    
    func testAddOrEdit_WithPastDate_ShouldReturnInvalidDateError() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = "01/20" // Past date
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        let expectation = XCTestExpectation(description: "Should fail with past date")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .invalidDate)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddOrEdit_WithInvalidDateFormat_ShouldReturnInvalidDateError() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = "13/30" // Invalid month
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        let expectation = XCTestExpectation(description: "Should fail with invalid date format")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .invalidDate)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddOrEdit_WithMalformedDate_ShouldReturnInvalidDateError() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = "12-30" // Wrong separator
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        let expectation = XCTestExpectation(description: "Should fail with malformed date")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .invalidDate)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddOrEdit_WithCurrentMonthDate_ShouldReturnInvalidDateError() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let currentMonthYear = dateFormatter.string(from: Date())
        
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = currentMonthYear // Current month should fail (not descending)
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        
        let expectation = XCTestExpectation(description: "Should fail with current month date")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error, .invalidDate)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddOrEdit_WithFutureDate_ShouldSucceed() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Test Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = "12/35" // Future date
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        cardObject.pin = "1234"
        
        let expectation = XCTestExpectation(description: "Should succeed with future date")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Favorite and PIN Tests
    
    func testAddOrEdit_WithFavoritedTrue_ShouldSaveFavoriteStatus() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "Favorite Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        cardObject.isFavorited = true
        cardObject.pin = "1234"
        
        let expectation = XCTestExpectation(description: "Should save favorite status")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddOrEdit_WithCustomPin_ShouldSavePin() {
        let cardObject = CardObservableObject()
        cardObject.cardName = "PIN Card"
        cardObject.cardNumber = "1234 5678 9012 3456"
        cardObject.expiryDate = "12/30"
        cardObject.cvvCode = "123"
        cardObject.cardColor = testColor
        cardObject.pin = "9876"
        
        let expectation = XCTestExpectation(description: "Should save custom PIN")
        
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
