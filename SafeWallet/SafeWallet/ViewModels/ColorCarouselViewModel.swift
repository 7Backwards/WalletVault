//
//  ColorCarouselViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI

class ColorCarouselViewModel: ViewModelProtocol {
    @Published var appManager: AppManager
    @Binding var cardColor: String
    
    init(appManager: AppManager, cardColor: Binding<String>) {
        self.appManager = appManager
        self._cardColor = cardColor
    }
    
    func getCardBackgroundOpacity() -> Double {
        appManager.constants.cardBackgroundOpacity
    }
}
