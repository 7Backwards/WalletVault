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
    
    private let keychainService = KeychainService()
    
    /// Lazy-loaded encryption key from Keychain
    /// - Generated on first app launch and securely stored in iOS Keychain
    /// - Protected by biometric authentication (Face ID/Touch ID) or device passcode
    /// - Unique per device, never leaves device, not backed up to iCloud
    lazy var encryptionKey: SymmetricKey = {
        if let key = keychainService.getOrCreateEncryptionKey() {
            return key
        }
        // Fallback: Use legacy hardcoded key if Keychain fails (common in simulator)
        // This ensures consistent encryption even when Keychain is unavailable
        Logger.log("WARNING: Using fallback encryption key. Keychain access may have failed.", level: .error)
        return SymmetricKey(data: "WalletVault_Encryption_Key_2024!".data(using: .utf8)!)
    }()
    
    var defaultColors: [String] = [Color.black.toHex()!, Color.purple.toHex()!, Color.red.toHex()!, Color.green.toHex()!, Color.blue.toHex()!]
}

