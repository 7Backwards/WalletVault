//
//  AddOrEditMyCardViewModelTests.swift
//  SafeWalletTests
//
//  Created by Gonçalo on 10/03/2024.
//

@testable import SafeWallet
import XCTest


class AddOrEditMyCardViewModelTests: XCTestCase {
    
    func testAddOrEdit_WhenAdding_ShouldCallCompletionWithSuccess() {
        let mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        let appManager = AppManager(context: mockContext) 
        let viewModel = AddOrEditMyCardViewModel(appManager: appManager)
        
        let card = Card(context: mockContext)
        card.cardName = "Test Card"
        card.cardNumber = "1234567890123456"
        card.expiryDate = "12/25"
        card.cvvCode = "123"
        card.cardColor = "Blue"
        card.isFavorited = false
        card.pin = "1234"
        
        let cardObservableObject = CardObservableObject(card: card)
        
        cardObservableObject.cardName = "New card name"
        
        
        let expectation = XCTestExpectation(description: "Add or edit completion handler called")
        
        viewModel.addOrEdit(cardObject: cardObservableObject) { result in
            expectation.fulfill()
            let fetchedCard = mockContext.fetchCard(withID: card.objectID)
            XCTAssertEqual(fetchedCard?.cardName, "New card name")
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
