//
//  Card+CoreDataClass.swift
//  SafeWallet
//
//  Created by Gonçalo on 21/12/2023.
//
//

import Foundation
import CoreData

@objc(Card)
public class Card: NSManagedObject {}

extension NSManagedObjectContext {
    func fetchCard(withID id: NSManagedObjectID) -> Card? {
        return self.object(with: id) as? Card
    }
}
