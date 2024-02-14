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
}

extension Card : Identifiable {}
