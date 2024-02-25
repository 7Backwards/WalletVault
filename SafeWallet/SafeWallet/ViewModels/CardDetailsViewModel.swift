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
    @Published var cardObject: CardObservableObject
    @Binding var isEditable: Bool
    @Published var isUnlocked: Bool
    let setIsFavorited: (Bool) -> Void
    
    init(appManager: AppManager, cardObject: CardObservableObject, isEditing: Binding<Bool>, isUnlocked: Bool, setIsFavorited: @escaping (Bool) -> Void) {
        self.appManager = appManager
        self.cardObject = cardObject
        self._isEditable = isEditing
        self.isUnlocked = isUnlocked
        self.setIsFavorited = setIsFavorited
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
}
