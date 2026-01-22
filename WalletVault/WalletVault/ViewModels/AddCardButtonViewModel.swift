//
//  AddCardButtonViewModel.swift
//  WalletVault
//
//  Created by Gonçalo on 25/02/2024.
//

import SwiftUI

class AddCardButtonViewModel: AddOrEditMyCardViewModel {
    @Binding var isEditable: Bool
    @Published var cardObject: CardObservableObject
    var showAlert: (String) -> Void
    
    init(appManager: AppManager, cardObject: CardObservableObject, isEditable: Binding<Bool>, showAlert: @escaping (String) -> Void) {
        self._isEditable = isEditable
        self.cardObject = cardObject
        self.showAlert = showAlert
        super.init(appManager: appManager)
    }
}
