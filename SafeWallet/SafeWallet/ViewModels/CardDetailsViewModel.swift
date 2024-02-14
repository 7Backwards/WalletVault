//
//  CardDetailsViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 26/12/2023.
//

import Foundation
import SwiftUI
import CoreData

class CardDetailsViewModel: ViewModelProtocol {
    @Published var appManager: AppManager
    
    init(appManager: AppManager) {
        self.appManager = appManager
    }

    func formatCardNumber(_ number: String) -> String {
        appManager.utils.formatCardNumber(number)
    }
    
    func getCardIssuerImage(cardNumber: String) -> Image? {
        appManager.utils.getCardIssuerImage(cardNumber: cardNumber)
    }
    
    func getCardBackgroundOpacity() -> Double {
        appManager.constants.cardBackgroundOpacity
    }
    
    func setCardIsFavorited(cardId: NSManagedObjectID, isFavorited: Bool, completion: ((Bool) -> Void)? = nil) {
        appManager.actionManager.doAction(action: .setIsFavorited(id: cardId, isFavorited), completion: completion)
    }
}
