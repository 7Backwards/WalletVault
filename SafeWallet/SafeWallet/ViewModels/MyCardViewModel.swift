//
//  MyCardViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 08/01/2024.
//

import SwiftUI

class MyCardViewModel: AddOrEditMyCardViewModel, ViewModelProtocol {
    @Published var shouldShowDeleteConfirmation: Bool = false
    @Published var undoCardInfo = CardInfo()
    @Published private var autoLockTimer: Timer?
    @Published var activeAlert: ActiveAlert?
    @Published var activeShareSheet: ActiveShareSheet?
    @Published var isEditable = false
    @Published var showingShareSheet = false
    @Published var cardObject: CardObservableObject
    var presentationMode: PresentationMode?
    
    enum ActiveAlert: Identifiable {
        case deleteConfirmation
        case error(String)
        
        var id: String {
            switch self {
            case .deleteConfirmation:
                return "deleteConfirmation"
            case .error(let errorMessage):
                return errorMessage
            }
        }
    }
    
    enum ActiveShareSheet: Identifiable {
        case outsideShare
        case insideShare
        
        var id: String {
            switch self {
            case .outsideShare:
                return "outsideShare"
            case .insideShare:
                return "insideShare"
            }
        }
    }
    
    init(cardObject: CardObservableObject, appManager: AppManager) {
        appManager.utils.protectScreen()
        self.cardObject = cardObject
        super.init(appManager: appManager)
    }
    
    deinit {
        appManager.utils.unprotectScreen()
    }

    func delete(completion: @escaping (Bool) -> Void ) {
        guard let id = cardObject.id else {
            Logger.log("Error getting card on method \(#function)", level: .error)
            return
        }
        appManager.actionManager.doAction(action: .removeCard(id), completion: completion)
    }
    
    func updateCardColor(cardColor: String) {
        guard let id = cardObject.id else {
            Logger.log("Error getting card on method \(#function)", level: .error)
            return
        }
        appManager.actionManager.doAction(action: .changeCardColor(id, cardColor))
    }
    
    func saveCurrentCard() {
        undoCardInfo = CardInfo(cardName: cardObject.cardName, cardNumber: cardObject.cardNumber, expiryDate: cardObject.expiryDate, cvvCode: cardObject.cvvCode, cardColor: cardObject.cardColor, isFavorited: cardObject.isFavorited, pin: cardObject.pin)
    }
    
    func undo() {
        Logger.log("Undo card changes")
        cardObject.cardName = undoCardInfo.cardName
        cardObject.cardNumber = undoCardInfo.cardNumber
        cardObject.cardColor = undoCardInfo.cardColor
        cardObject.cvvCode = undoCardInfo.cvvCode
        cardObject.expiryDate = undoCardInfo.expiryDate
        cardObject.isFavorited = undoCardInfo.isFavorited
        cardObject.pin = undoCardInfo.pin
    }
    
    func startAutoLockTimer() {
        resetAutoLockTimer()
        self.autoLockTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
            Logger.log("AutoLock expired, dismissing view")
            self.presentationMode?.dismiss()
        }
    }
    
    func resetAutoLockTimer() {
        autoLockTimer?.invalidate()
    }
}
