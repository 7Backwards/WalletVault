//
//  CardObservableObject.swift
//  WalletVault
//
//  Created by Gonçalo on 14/02/2024.
//

import Foundation
import CoreData
import SwiftUI

class CardObservableObject: ObservableObject {
    @Published var cardName: String = ""
    @Published var cardNumber: String = ""
    @Published var expiryDate: String = ""
    @Published var cvvCode: String = ""
    @Published var cardColor: ColorEntity? = nil
    @Published var isFavorited: Bool = false
    @Published var pin: String = ""
    @Published var id: NSManagedObjectID? = nil
    
    init(card: Card) {
        cardName = card.cardName
        cardNumber = card.cardNumber
        expiryDate = card.expiryDate
        cvvCode = card.cvvCode
        cardColor = card.cardColor
        isFavorited = card.isFavorited
        pin = card.pin
        id = card.objectID
    }
    
    init(cardInfo: CardInfo) {
        cardName = cardInfo.cardName
        cardNumber = cardInfo.cardNumber
        expiryDate = cardInfo.expiryDate
        cvvCode = cardInfo.cvvCode
        cardColor = cardInfo.cardColor
        isFavorited = cardInfo.isFavorited
        pin = cardInfo.pin
    }
    
    init() {}
    
    func getCardInfo() -> CardInfo {
        CardInfo(cardName: cardName, cardNumber: cardNumber, expiryDate: expiryDate, cvvCode: cvvCode, cardColor: cardColor, isFavorited: isFavorited, pin: pin)
    }
}
