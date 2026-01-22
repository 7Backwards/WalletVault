//
//  Card+CoreDataProperties.swift
//  WalletVault
//
//  Created by Gonçalo on 31/08/2024.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var cardName: String
    @NSManaged public var cardNumber: String
    @NSManaged public var cvvCode: String
    @NSManaged public var expiryDate: String
    @NSManaged public var isFavorited: Bool
    @NSManaged public var pin: String
    @NSManaged public var cardColor: ColorEntity?

}

extension Card : Identifiable {

}

public class CardInfo {
    public var cardName: String = ""
    public var cardNumber: String = ""
    public var expiryDate: String = ""
    public var cvvCode: String = ""
    public var cardColor: ColorEntity?
    public var isFavorited: Bool = false
    public var pin: String = ""
    
    init(cardName: String = "", cardNumber: String = "", expiryDate: String = "", cvvCode: String = "", cardColor: ColorEntity? = nil, isFavorited: Bool = false, pin: String = "") {
        self.cardName = cardName
        self.cardNumber = cardNumber
        self.expiryDate = expiryDate
        self.cvvCode = cvvCode
        self.cardColor = cardColor
        self.isFavorited = isFavorited
        self.pin = pin
    }
}
