//
//  ColorCarouselViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI

class ColorCarouselViewModel: ViewModelProtocol {
    @Published var appManager: AppManager
    
    init(appManager: AppManager) {
        self.appManager = appManager
    }
    
    func getCardBackgroundOpacity() -> Double {
        appManager.constants.cardBackgroundOpacity
    }
}
