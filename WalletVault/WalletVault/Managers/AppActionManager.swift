//
//  AppActionManager.swift
//  WalletVault
//
//  Created by Gonçalo on 18/01/2024.
//

import CoreData

protocol AppActionManagerProtocol {
    func doAction(action: AppAction, completion: ((Bool) -> Void)?)
}

enum AppAction {
    case addCard(cardName: String, cardNumber: String, expiryDate: String, cvvCode: String, cardColor: ColorEntity?, isFavorited: Bool, pin: String)
    case editCard(id: NSManagedObjectID, cardName: String, cardNumber: String, expiryDate: String, cvvCode: String, cardColor: ColorEntity?, isFavorited: Bool, pin: String)
    case removeCard(NSManagedObjectID)
    case removeCards([NSManagedObjectID])
    case changeCardColor(NSManagedObjectID, ColorEntity)
    case setIsFavorited(id: NSManagedObjectID, Bool)
    case insertNewColor(hexValue: String, isDefault: Bool)
    case removeColor(hexValue: String)
    case getColor(hexValue: String, completion: (ColorEntity?) -> Void)
}

class AppActionManager: AppActionManagerProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        Logger.log("AppActionManager initialized with context: \(context)")
    }
    
    func doAction(action: AppAction, completion: ((Bool) -> Void)? = nil) {
        Logger.log("Performing action: \(action)")
        
        func saveWithCompletion(saveCompletion: ((Bool) -> Void)? = nil ) {
            do {
                try context.save()
                Logger.log("Context saved successfully")
                if let saveCompletion {
                    saveCompletion(true)
                } else {
                    completion?(true)
                }
            } catch {
                Logger.log("Failed to save context: \(error)", level: .error)
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
                    Logger.log("Adding new card with number: \(cardNumber)")
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
                    Logger.log("A card with the same number already exists.")
                    completion?(false)
                }
            } catch {
                Logger.log("Failed to fetch cards: \(error)", level: .error)
                completion?(false)
            }
        case .editCard(let id, let cardName, let cardNumber, let expiryDate, let cvvCode, let cardColor, let isFavorited, let pin):
            Logger.log("Editing card with id: \(id)")
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
            Logger.log("Removing card with id: \(id)")
            if let card = getCard(id) {
                removeCardNotifications(cardID: id)
                context.delete(card)
                saveWithCompletion()
            } else {
                Logger.log("Failed to remove card with id \(id), no card is present", level: .error)
                completion?(false)
            }
        case .removeCards(let ids):
            Logger.log("Removing cards with ids: \(ids)")
            ids.forEach {
                if let card = getCard($0) {
                    removeCardNotifications(cardID: $0)
                    context.delete(card)
                } else {
                    Logger.log("Failed to remove card with id \($0), no card is present", level: .error)
                }
            }
            saveWithCompletion()
            
        case .changeCardColor(let id, let newCardColor):
            Logger.log("Changing card color for id: \(id) to color: \(newCardColor)")
            if let card = getCard(id) {
                card.cardColor = newCardColor
            }
            saveWithCompletion()
        case .setIsFavorited(let cardId, let isFavorited):
            Logger.log("Setting isFavorited for card id: \(cardId) to \(isFavorited)")
            guard let card = context.fetchCard(withID: cardId) else {
                completion?(false)
                return
            }
            card.isFavorited = isFavorited
            saveWithCompletion()
        case .insertNewColor(let hexValue, let isDefault):
            Logger.log("Inserting new color with hexValue: \(hexValue)")
            
            let color = ColorEntity(context: context)
            color.hexValue = hexValue
            color.isDefault = isDefault
            
            saveWithCompletion()
        case .removeColor(let hexValue):
            Logger.log("Attempting to remove color with hexValue: \(hexValue)")

            // Fetch the color by hex value
            let fetchRequest: NSFetchRequest<ColorEntity> = ColorEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "hexValue == %@", hexValue)
            
            do {
                let colors = try context.fetch(fetchRequest)
                
                if let color = colors.first {
                    if color.isDefault {
                        Logger.log("Cannot remove default color: \(hexValue)", level: .warning)
                        completion?(false)
                    } else {
                        Logger.log("Removing color with hexValue: \(hexValue)")
                        context.delete(color)
                        saveWithCompletion()
                    }
                } else {
                    Logger.log("No color found with hexValue: \(hexValue)", level: .error)
                    completion?(false)
                }
            } catch {
                Logger.log("Failed to fetch color with hexValue: \(hexValue), error: \(error)", level: .error)
                completion?(false)
            }
        case .getColor(let hexValue, let colorCompletion):
            Logger.log("Fetching color with hexValue: \(hexValue)")

            // Fetch the color by hex value
            let fetchRequest: NSFetchRequest<ColorEntity> = ColorEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "hexValue == %@", hexValue)
            
            do {
                let colors = try context.fetch(fetchRequest)
                
                if let color = colors.first {
                    Logger.log("Found color with hexValue: \(hexValue)")
                    colorCompletion(color)
                } else {
                    Logger.log("No color found with hexValue: \(hexValue)", level: .error)
                    colorCompletion(nil)
                }
            } catch {
                Logger.log("Failed to fetch color with hexValue: \(hexValue), error: \(error)", level: .error)
                colorCompletion(nil)
            }
        }
    }
    
    func setupDefaultColors(colors: [String]) {
        Logger.log("Setting up default colors")
        
        // Fetch existing colors from Core Data
        let fetchRequest: NSFetchRequest<ColorEntity> = ColorEntity.fetchRequest()
        
        do {
            let existingColors = try context.fetch(fetchRequest).map { $0.hexValue }
            let missingColors = colors.filter { !existingColors.contains($0) }
            
            guard !missingColors.isEmpty else {
                Logger.log("All default colors are already in the database.")
                return
            }
            
            // Insert missing colors
            for hexValue in missingColors {
                doAction(action: .insertNewColor(hexValue: hexValue, isDefault: true))
            }
            
            Logger.log("Default colors setup completed successfully.")
            
        } catch {
            Logger.log("Failed to fetch or save colors: \(error)", level: .error)
        }
    }
    
    private func getCard(_ id: NSManagedObjectID) -> Card? {
        Logger.log("Fetching card with id: \(id)")
        return context.fetchCard(withID: id)
    }
}
