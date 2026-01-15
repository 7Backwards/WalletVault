//
//  AppConstants.swift
//  WalletVault
//
//  Created by Gonçalo on 21/01/2024.
//

import SwiftUI
import CryptoKit

enum AddCardErrorType: Error {
    case invalidDate
    case savingError
    case shortCardNumber
}

class AppConstants: ObservableObject {
    @Published var cardBackgroundOpacity = 0.35
    @Published var colorCircleSize: CGFloat = 40
    @Published var cardHorizontalMarginSpacing: CGFloat = 20
    @Published var cardVerticalMarginSpacing: CGFloat = 20
    @Published var qrCodeSize: CGSize = CGSize(width: 300, height: 300)
    @Published var autoLockTimer: TimeInterval = 30 // Seconds
    let encryptionKey = SymmetricKey(data: "WalletVault_Encryption_Key_2024!".data(using: .utf8)!)
    var defaultColors: [String] = [Color.black.toHex()!, Color.purple.toHex()!, Color.red.toHex()!, Color.green.toHex()!, Color.blue.toHex()!]
}
