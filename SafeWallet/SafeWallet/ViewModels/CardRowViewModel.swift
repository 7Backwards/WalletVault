//
//  CardRowViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 25/02/2024.
//

import SwiftUI

class CardRowViewModel: ViewModelProtocol {
    @Published var appManager: AppManager
    @Published var cardObject: CardObservableObject
    @Published var isEditable = false
    @Binding var activeAlert: CardListViewModel.ActiveAlert?
    
    init(appManager: AppManager, cardObject: CardObservableObject, activeAlert: Binding<CardListViewModel.ActiveAlert?>) {
        self.appManager = appManager
        self.cardObject = cardObject
        self._activeAlert = activeAlert
    }
}
