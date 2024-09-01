//
//  MyCardViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 08/01/2024.
//

import SwiftUI
import Combine

class MyCardViewModel: AddOrEditMyCardViewModel, ViewModelProtocol {
    @Published var shouldShowDeleteConfirmation: Bool = false
    @Published var undoCardInfo = CardInfo()
    @Published private var autoLockTimer: Timer?
    @Published var activeAlert: ActiveAlert?
    @Published var activeShareSheet: ActiveShareSheet?
    @Published var isEditable = false 
    @Published var showingShareSheet = false
    @Published var cardObject: CardObservableObject
    @Published var shouldDismissView = false
    private var cancellables = Set<AnyCancellable>()
    
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
        
        setupObservers()
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
    
    func updateCardColor(cardColor: ColorEntity) {
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
        invalidateAutoLockTimer()
        Logger.log("Setting up auto lock timer")
        autoLockTimer = Timer.scheduledTimer(withTimeInterval: appManager.constants.autoLockTimer, repeats: false) { [weak self] _ in
            Logger.log("AutoLock expired, dismissing view") 
            self?.shouldDismissView = true
        }
    }
    
    func invalidateAutoLockTimer() {
        Logger.log("Invalidate auto lock timer")
        autoLockTimer?.invalidate()
    }
    
    private func setupObservers() {
        $isEditable
            .sink { [weak self] isEditable in
                if isEditable {
                    self?.invalidateAutoLockTimer()
                } else {
                    self?.startAutoLockTimer()
                }
            }
            .store(in: &cancellables)
        
        $activeShareSheet
            .sink { [weak self] activeShareSheet in
                if activeShareSheet != nil {
                    self?.invalidateAutoLockTimer()
                } else {
                    self?.startAutoLockTimer()
                }
            }
            .store(in: &cancellables)
        
        $activeAlert
            .sink { [weak self] activeAlert in
                if activeAlert != nil {
                    self?.invalidateAutoLockTimer()
                } else {
                    self?.startAutoLockTimer()
                }
            }
            .store(in: &cancellables)
    }
}
