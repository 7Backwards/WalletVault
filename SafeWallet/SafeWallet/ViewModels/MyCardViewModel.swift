//
//  MyCardViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 08/01/2024.
//

import SwiftUI

class MyCardViewModel: AddOrEditMyCardViewModel, ViewModelProtocol {
    var card: Card
    @Published var shouldShowDeleteConfirmation: Bool = false
    
    init(card: Card, appManager: AppManager) {
        self.card = card
        appManager.utils.protectScreen()
        super.init(appManager: appManager)
    }
    
    deinit {
        appManager.utils.unprotectScreen()
    }

    func delete(completion: @escaping (Bool) -> Void ) {
        appManager.actionManager.doAction(action: .removeCard(card), completion: completion)
    }
    
    func updateCardColor(cardColor: String) {
        appManager.actionManager.doAction(action: .changeCardColor(card, cardColor))
    }
}
