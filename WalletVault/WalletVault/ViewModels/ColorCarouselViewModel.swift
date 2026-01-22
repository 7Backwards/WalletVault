//
//  ColorCarouselViewModel.swift
//  WalletVault
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI

class ColorCarouselViewModel: ViewModelProtocol {
    @Published var appManager: AppManager
    @Binding var cardColor: ColorEntity?
    
    init(appManager: AppManager, cardColor: Binding<ColorEntity?>) {
        self.appManager = appManager
        self._cardColor = cardColor
    }
    
    func getCardBackgroundOpacity() -> Double {
        appManager.constants.cardBackgroundOpacity
    }
    
    func addNewColor(hex: String) {
        appManager.actionManager.doAction(action: .insertNewColor(hexValue: hex, isDefault: false))
    }
    
    func removeSelectedColor() {
        guard let hexValue = cardColor?.hexValue else { return }
        appManager.actionManager.doAction(action: .removeColor(hexValue: hexValue))
    }
}
