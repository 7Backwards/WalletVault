//
//  CardViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 14/02/2024.
//

import Foundation
import CoreData

class CardViewModel: ObservableObject {
    @Published var cardName: String = ""
    @Published var cardNumber: String = ""
    @Published var expiryDate: String = ""
    @Published var cvvCode: String = ""
    @Published var cardColor: String = ""
    @Published var isFavorited: Bool = false
    @Published var id: NSManagedObjectID?
    
    init(card: Card?) {
        cardName = card?.cardName ?? ""
        cardNumber = card?.cardNumber ?? ""
        expiryDate = card?.expiryDate ?? ""
        cvvCode = card?.cvvCode ?? ""
        cardColor = card?.cardColor ?? "systemBackground"
        isFavorited = card?.isFavorited ?? false
        id = card?.objectID
    }
}
