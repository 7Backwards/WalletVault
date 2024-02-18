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
    case removeCard(Card)
    case removeCards([Card])
    case changeCardColor(Card, String)
    case setIsFavorited(id: NSManagedObjectID, Bool)
}

class AppActionManager {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func doAction(action: AppAction, completion: ((Bool) -> Void)? = nil) {
        func saveWithCompletion() {
            do {
                try context.save()
                completion?(true)
            } catch {
                completion?(false)
            }
        }

        switch action {
        case .addCard(let cardName, let cardNumber, let expiryDate, let cvvCode, let cardColor, let isFavorited, let pin):
            let card = Card(context: context)
            card.cardNumber = cardNumber
            card.expiryDate = expiryDate
            card.cvvCode = cvvCode
            card.cardName = cardName
            card.cardColor = cardColor
            card.isFavorited = isFavorited
            card.pin = pin
            saveWithCompletion()
        case .editCard(let id, let cardName, let cardNumber, let expiryDate, let cvvCode, let cardColor, let isFavorited, let pin):
            if let card = context.fetchCard(withID: id) {
                card.cardName = cardName
                card.cardNumber = cardNumber
                card.expiryDate = expiryDate
                card.cvvCode = cvvCode
                card.cardColor = cardColor
                card.isFavorited = isFavorited
                card.pin = pin
            }
            saveWithCompletion()
        case .removeCard(let card):
            context.delete(card)
            saveWithCompletion()
        case .removeCards(let cards):
            cards.forEach {
                context.delete($0)
            }
            saveWithCompletion()
        case .changeCardColor(let card, let newCardColor):
            card.cardColor = newCardColor
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
}
