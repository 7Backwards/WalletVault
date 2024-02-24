//
//  Card+CoreDataProperties.swift
//  SafeWallet
//
//  Created by Gonçalo on 21/12/2023.
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
    @NSManaged public var expiryDate: String
    @NSManaged public var cvvCode: String
    @NSManaged public var cardColor: String
    @NSManaged public var isFavorited: Bool
    @NSManaged public var pin: String
}

extension Card : Identifiable {}


// Card representative object
public class CardInfo {
    public var cardName: String = ""
    public var cardNumber: String = ""
    public var expiryDate: String = ""
    public var cvvCode: String = ""
    public var cardColor: String = ""
    public var isFavorited: Bool = false
    public var pin: String = ""
    
    init(cardName: String = "", cardNumber: String = "", expiryDate: String = "", cvvCode: String = "", cardColor: String = "systemBackground", isFavorited: Bool = false, pin: String = "") {
        self.cardName = cardName
        self.cardNumber = cardNumber
        self.expiryDate = expiryDate
        self.cvvCode = cvvCode
        self.cardColor = cardColor
        self.isFavorited = isFavorited
        self.pin = pin
    }
}
