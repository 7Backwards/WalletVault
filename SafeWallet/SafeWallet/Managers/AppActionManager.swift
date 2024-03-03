//
//  AppActionManager.swift
//  SafeWallet
//
//  Created by Gonçalo on 18/01/2024.
//

import CoreData

enum AppAction {
    case addCard(cardName: String, cardNumber: String, expiryDate: String, cvvCode: String, cardColor: String, isFavorited: Bool, pin: String)
    case editCard(id: NSManagedObjectID, cardName: String, cardNumber: String, expiryDate: String, cvvCode: String, cardColor: String, isFavorited: Bool, pin: String)
    case removeCard(NSManagedObjectID)
    case removeCards([NSManagedObjectID])
    case changeCardColor(NSManagedObjectID, String)
    case setIsFavorited(id: NSManagedObjectID, Bool)
}

class AppActionManager {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func doAction(action: AppAction, completion: ((Bool) -> Void)? = nil) {
        func saveWithCompletion(saveCompletion: ((Bool) -> Void)? = nil ) {
            do {
                try context.save()
                if let saveCompletion {
                    saveCompletion(true)
                } else {
                    completion?(true)
                }
            } catch {
                if let saveCompletion {
                    saveCompletion(false)
                } else {
                    completion?(false)
                }
            }
        }

        switch action {
        case .addCard(let cardName, let cardNumber, let expiryDate, let cvvCode, let cardColor, let isFavorited, let pin):
            
            let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "cardNumber == %@", cardNumber)
            
            do {
                let existingCards = try context.fetch(fetchRequest)
                
                if existingCards.isEmpty {
                    let card = Card(context: context)
                    card.cardNumber = cardNumber
                    card.expiryDate = expiryDate
                    card.cvvCode = cvvCode
                    card.cardName = cardName
                    card.cardColor = cardColor
                    card.isFavorited = isFavorited
                    card.pin = pin

                    saveWithCompletion() {
                        scheduleCardNotifications(cardID: card.objectID, cardName: cardName, expiryDate: expiryDate)
                        completion?($0)
                    }
                } else {
                    print("A card with the same number already exists.")
                    completion?(false)
                }
            } catch {
                print("Failed to fetch cards: \(error)")
                completion?(false)
            }
        case .editCard(let id, let cardName, let cardNumber, let expiryDate, let cvvCode, let cardColor, let isFavorited, let pin):
            if let card = getCard(id) {
                if card.expiryDate != expiryDate || card.cardName != cardName {
                    scheduleCardNotifications(cardID: id, cardName: cardName, expiryDate: expiryDate)
                }
                card.cardName = cardName
                card.cardNumber = cardNumber
                card.expiryDate = expiryDate
                card.cvvCode = cvvCode
                card.cardColor = cardColor
                card.isFavorited = isFavorited
                card.pin = pin 
            }
            saveWithCompletion()
        case .removeCard(let id):
            if let card = getCard(id) {
                removeCardNotifications(cardID: id)
                context.delete(card)
            }
            saveWithCompletion()
        case .removeCards(let ids):
            ids.forEach {
                if let card = getCard($0) {
                    removeCardNotifications(cardID: $0)
                    context.delete(card)
                }
            }
            saveWithCompletion()
        case .changeCardColor(let id, let newCardColor):
            if let card = getCard(id) {
                card.cardColor = newCardColor
            }
            saveWithCompletion()
        case .setIsFavorited(let cardId, let isFavorited):
            guard let card = context.fetchCard(withID: cardId) else {
                completion?(false)
                return
            }
            card.isFavorited = isFavorited
            saveWithCompletion()
        }
    }
    
    private func getCard(_ id: NSManagedObjectID) -> Card? {
        context.fetchCard(withID: id)
    }
}
