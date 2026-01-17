//
//  KeychainService.swift
//  WalletVault
//
//  Created by Gonçalo on 17/01/2026.
//

import Foundation
import CryptoKit
import Security

/// Service responsible for securely managing encryption keys in the iOS Keychain
/// - Keys are protected by device hardware security
/// - Requires biometric authentication (Face ID/Touch ID) or device passcode
/// - Keys do not sync to iCloud and are tied to the device
class KeychainService {
    private let service = "com.walletvault.encryptionkey"
    private let account = "cardDataEncryptionKey"
    
    // MARK: - Key Management
    
    /// Retrieves the existing encryption key from Keychain, or creates a new one if none exists
    /// - Returns: A SymmetricKey for AES-256 encryption, or nil if key creation/retrieval fails
    func getOrCreateEncryptionKey() -> SymmetricKey? {
        // 1. Try to retrieve existing key from Keychain
        if let existingKey = retrieveKey() {
            Logger.log("Retrieved existing encryption key from Keychain")
            return existingKey
        }
        
        // 2. Generate new key on first launch
        Logger.log("Generating new encryption key (first launch)")
        let newKey = SymmetricKey(size: .bits256)
        
        // 3. Store in Keychain with biometric protection
        if storeKey(newKey) {
            Logger.log("Successfully stored new encryption key in Keychain")
            return newKey
        }
        
        Logger.log("Failed to store encryption key in Keychain", level: .error)
        return nil
    }
    
    // MARK: - Private Methods
    
    /// Retrieves the encryption key from Keychain
    /// - Returns: SymmetricKey if found, nil otherwise
    private func retrieveKey() -> SymmetricKey? {
        // Fetch from Keychain with kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        // This means:
        // - Key is encrypted with device hardware key
        // - Only accessible when device is unlocked
        // - NOT backed up to iCloud/computer
        // - Tied to this specific device
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true
        ] as [String: Any]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            if status != errSecItemNotFound {
                Logger.log("Keychain retrieval failed with status: \(status)", level: .warning)
            }
            return nil
        }
        
        return SymmetricKey(data: data)
    }
    
    /// Stores the encryption key in Keychain with biometric protection
    /// - Parameter key: The SymmetricKey to store
    /// - Returns: Boolean indicating success
    private func storeKey(_ key: SymmetricKey) -> Bool {
        let keyData = key.withUnsafeBytes { Data($0) }
        
        var attributes: [String: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: keyData,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as [String: Any]
        
        // Add biometric protection if available
        if let accessControl = createBiometricAccessControl() {
            attributes[kSecAttrAccessControl as String] = accessControl
            Logger.log("Keychain key will be protected by biometric authentication")
        } else {
            Logger.log("Biometric protection not available, using device unlock only", level: .warning)
        }
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            Logger.log("Key already exists in Keychain", level: .warning)
            return false
        }
        
        return status == errSecSuccess
    }
    
    /// Creates access control for biometric authentication
    /// - Returns: SecAccessControl if successful, nil otherwise
    private func createBiometricAccessControl() -> SecAccessControl? {
        var error: Unmanaged<CFError>?
        
        // Biometric (Face ID, Touch ID) OR Device passcode as fallback
        let flags: SecAccessControlCreateFlags = [
            .biometryCurrentSet,  // Biometric (Face ID, Touch ID)
            .or,                  // OR
            .devicePasscode       // Device passcode as fallback
        ]
        
        let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            &error
        )
        
        if let error = error {
            Logger.log("Failed to create biometric access control: \(error)", level: .warning)
            return nil
        }
        
        return (accessControl as SecAccessControl?)
    }
    
    // MARK: - Key Deletion
    
    /// Deletes the encryption key from Keychain
    /// - Returns: Boolean indicating success
    /// - Warning: This will make all encrypted data unrecoverable
    func deleteKey() -> Bool {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            Logger.log("Encryption key deleted from Keychain")
        } else if status == errSecItemNotFound {
            Logger.log("No encryption key found to delete", level: .warning)
        } else {
            Logger.log("Failed to delete encryption key, status: \(status)", level: .error)
        }
        
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
