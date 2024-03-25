//
//  AppActionManagerTests.swift
//  SafeWalletTests
//
//  Created by Gonçalo on 10/03/2024.
//

@testable import SafeWallet
import CoreData
import XCTest

class AppActionManagerTests: XCTestCase {
    var sut: AppActionManager!
    var mockContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        mockContext = TestUtils.setUpInMemoryManagedObjectContext()
        sut = AppActionManager(context: mockContext)
    }

    override func tearDown() {
        sut = nil
        mockContext = nil
        super.tearDown()
    }

    func testAddCard_ShouldSaveCard() {
        let expectation = self.expectation(description: "Card saved")
        sut.doAction(action: .addCard(cardName: "Test Card", cardNumber: "1234567890123456", expiryDate: "12/25", cvvCode: "123", cardColor: "Blue", isFavorited: false, pin: "1234")) { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRemoveCard_ShouldDeleteCard() {
        let card = addTestCardToContext()
        
        let expectation = self.expectation(description: "Card removed")
        sut.doAction(action: .removeCard(card.objectID)) { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEditCard_ShouldUpdateCard() {
        let card = addTestCardToContext()
        try? mockContext.save()
        let newCardName = "Edited Test Card"        

        let expectation = self.expectation(description: "Card edited")
        
        sut.doAction(action: .editCard(id: card.objectID, cardName: newCardName, cardNumber: card.cardNumber, expiryDate: card.expiryDate, cvvCode: card.cvvCode, cardColor: card.cardColor, isFavorited: card.isFavorited, pin: card.pin)) { success in
            XCTAssertTrue(success)
        
            let editedCard = self.mockContext.fetchCard(withID: card.objectID)
            XCTAssertEqual(editedCard?.cardName, newCardName)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRemoveMultipleCards_ShouldDeleteCards() {
        let card1 = addTestCardToContext()
        let card2 = addTestCardToContext()
        try? mockContext.save()
        
        let expectation = self.expectation(description: "Cards removed")
        
        sut.doAction(action: .removeCards([card1.objectID, card2.objectID])) { success in
            XCTAssertTrue(success)
            
            let fetchResults = self.fetchAllCards()
            XCTAssertTrue(fetchResults.isEmpty)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testChangeCardColor_ShouldUpdateColor() {
        let card = addTestCardToContext()
        let newColor = "Red"
        try? mockContext.save()

        let expectation = self.expectation(description: "Card color changed")

        sut.doAction(action: .changeCardColor(card.objectID, newColor)) { success in
            XCTAssertTrue(success)

            let updatedCard = self.mockContext.fetchCard(withID: card.objectID)
            XCTAssertEqual(updatedCard?.cardColor, newColor)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSetIsFavorited_ShouldUpdateFavoritedStatus() {
        let card = addTestCardToContext()
        let favoritedStatus = !card.isFavorited
        try? mockContext.save()

        let expectation = self.expectation(description: "Card favorited status changed")

        sut.doAction(action: .setIsFavorited(id: card.objectID, favoritedStatus)) { success in
            XCTAssertTrue(success)

            let updatedCard = self.mockContext.fetchCard(withID: card.objectID)
            XCTAssertEqual(updatedCard?.isFavorited, favoritedStatus)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }


    private func addTestCardToContext() -> Card {
        let card = Card(context: mockContext)
        card.cardName = "Test Card"
        card.cardNumber = "1234567890123456"
        card.expiryDate = "12/25"
        card.cvvCode = "123"
        card.cardColor = "Blue"
        card.isFavorited = false
        card.pin = "1234"
        return card
    }
    
    private func fetchAllCards() -> [Card] {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        do {
            let results = try mockContext.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
}
