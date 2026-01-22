//
//  AppUtils+EncryptedStorage.swift
//  WalletVault
//
//  Created by Gonçalo on 17/01/2026.
//

import Foundation
import CryptoKit

/// Extension to handle encryption/decryption for Core Data storage
/// - Provides transparent encryption with backward compatibility
/// - Uses "ENCRYPTED:" prefix to identify encrypted values
extension AppUtils {
    private var encryptedPrefix: String { "ENCRYPTED:" }
    
    /// Legacy hardcoded key for backward compatibility with old encrypted data
    private var legacyEncryptionKey: SymmetricKey {
        SymmetricKey(data: "WalletVault_Encryption_Key_2024!".data(using: .utf8)!)
    }
    
    /// Encrypts a value for storage in Core Data
    /// - Parameter value: The plaintext string to encrypt
    /// - Returns: Encrypted string with "ENCRYPTED:" prefix, or nil if encryption fails
    func encryptForStorage(_ value: String) -> String? {
        guard !value.isEmpty else {
            return value  // Don't encrypt empty strings
        }
        
        guard let appManager = appManager else {
            Logger.log("AppManager is nil in encryptForStorage", level: .error)
            return nil
        }
        
        guard let encryptedData = encryptString(value, using: appManager.constants.encryptionKey) else {
            Logger.log("Failed to encrypt value for storage", level: .error)
            return nil
        }
        
        return encryptedPrefix + encryptedData
    }
    
    /// Decrypts a value from Core Data storage
    /// - Parameter value: The potentially encrypted string
    /// - Returns: Plaintext string, or original value if not encrypted (backward compatibility)
    func decryptFromStorage(_ value: String) -> String? {
        guard value.hasPrefix(encryptedPrefix) else {
            // Not encrypted (backward compatibility with old plaintext data)
            return value
        }
        
        let encryptedPart = String(value.dropFirst(encryptedPrefix.count))
        
        guard let appManager = appManager else {
            Logger.log("AppManager is nil in decryptFromStorage - cannot decrypt!", level: .error)
            // Return a placeholder instead of encrypted gibberish
            return "••••" // Redacted placeholder
        }
        
        // Try to decrypt with current Keychain key
        if let decrypted = decryptString(encryptedPart, using: appManager.constants.encryptionKey) {
            return decrypted
        }
        
        // Fallback: Try with legacy hardcoded key for backward compatibility
        Logger.log("Trying to decrypt with legacy hardcoded key (migration needed)", level: .warning)
        if let decrypted = decryptString(encryptedPart, using: legacyEncryptionKey) {
            Logger.log("Successfully decrypted with legacy key - card will be re-encrypted on next save", level: .warning)
            return decrypted
        }
        
        Logger.log("Failed to decrypt value with both current and legacy keys", level: .error)
        return "••••" // Redacted placeholder
    }
    
    /// Checks if a value is encrypted
    /// - Parameter value: The string to check
    /// - Returns: Boolean indicating if value has encryption prefix
    func isEncrypted(_ value: String) -> Bool {
        return value.hasPrefix(encryptedPrefix)
    }
}

