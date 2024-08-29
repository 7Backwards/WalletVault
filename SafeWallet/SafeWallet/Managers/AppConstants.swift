//
//  AppConstants.swift
//  SafeWallet
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
    @Published var colors: [Color] = [.black, .purple, .red, .orange, .green, .blue, .yellow]
    @Published var colorCircleSize: CGFloat = 40
    @Published var cardHorizontalMarginSpacing: CGFloat = 20
    @Published var cardVerticalMarginSpacing: CGFloat = 20
    @Published var qrCodeSize: CGSize = CGSize(width: 300, height: 300)
    @Published var autoLockTimer: TimeInterval = 30 // Seconds
    let encryptionKey = SymmetricKey(data: "SafeWalletKey123".data(using: .utf8)!)
}
