//
//  AppUtils+Migration.swift
//  WalletVault
//
//  Created by Gonçalo on 17/01/2026.
//

import Foundation
import CoreData
import CryptoKit

/// Extension to handle migration of existing plaintext card data to encrypted format
extension AppUtils {
    
    /// Legacy hardcoded key for backward compatibility
    private var legacyEncryptionKey: SymmetricKey {
        SymmetricKey(data: "WalletVault_Encryption_Key_2024!".data(using: .utf8)!)
    }
    
    /// Migrates existing cards from plaintext or legacy encryption to current Keychain-based encryption
    /// - Parameter context: The Core Data managed object context
    /// - Note: This is a one-time migration that runs on app launch
    /// - Only encrypts cards that haven't already been encrypted (checks for "ENCRYPTED:" prefix)
    func migrateExistingCards(in context: NSManagedObjectContext) {
        Logger.log("Starting card encryption migration check...")
        
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        do {
            let cards = try context.fetch(fetchRequest)
            var migratedCount = 0
            var alreadyMigratedCount = 0
            var legacyKeyMigrationCount = 0
            
            for card in cards {
                var needsMigration = false
                
                // Check card number
                if !isEncrypted(card.cardNumber) {
                    // Plaintext - encrypt it
                    if let encrypted = encryptForStorage(card.cardNumber) {
                        card.cardNumber = encrypted
                        needsMigration = true
                    }
                } else if canDecryptWithLegacyKey(card.cardNumber) {
                    // Encrypted with old key - re-encrypt with new key
                    if let decrypted = decryptWithLegacyKey(card.cardNumber),
                       let reencrypted = encryptForStorage(decrypted) {
                        card.cardNumber = reencrypted
                        legacyKeyMigrationCount += 1
                        needsMigration = true
                    }
                }
                
                // Check CVV
                if !isEncrypted(card.cvvCode) {
                    if let encrypted = encryptForStorage(card.cvvCode) {
                        card.cvvCode = encrypted
                        needsMigration = true
                    }
                } else if canDecryptWithLegacyKey(card.cvvCode) {
                    if let decrypted = decryptWithLegacyKey(card.cvvCode),
                       let reencrypted = encryptForStorage(decrypted) {
                        card.cvvCode = reencrypted
                        needsMigration = true
                    }
                }
                
                // Check PIN
                if !card.pin.isEmpty {
                    if !isEncrypted(card.pin) {
                        if let encrypted = encryptForStorage(card.pin) {
                            card.pin = encrypted
                            needsMigration = true
                        }
                    } else if canDecryptWithLegacyKey(card.pin) {
                        if let decrypted = decryptWithLegacyKey(card.pin),
                           let reencrypted = encryptForStorage(decrypted) {
                            card.pin = reencrypted
                            needsMigration = true
                        }
                    }
                }
                
                if needsMigration {
                    migratedCount += 1
                    Logger.log("Migrated card: \(card.cardName)")
                } else {
                    alreadyMigratedCount += 1
                }
            }
            
            if migratedCount > 0 || legacyKeyMigrationCount > 0 {
                try context.save()
                if legacyKeyMigrationCount > 0 {
                    Logger.log("Migration complete: \(migratedCount) card(s) encrypted, \(legacyKeyMigrationCount) re-encrypted from legacy key")
                } else {
                    Logger.log("Migration complete: \(migratedCount) card(s) encrypted successfully")
                }
            } else if alreadyMigratedCount > 0 {
                Logger.log("Migration skipped: All \(alreadyMigratedCount) card(s) already encrypted with current key")
            } else {
                Logger.log("Migration complete: No cards found to migrate")
            }
            
        } catch {
            Logger.log("Migration failed: \(error)", level: .error)
        }
    }
    
    /// Checks if a value can be decrypted with the legacy key
    private func canDecryptWithLegacyKey(_ value: String) -> Bool {
        guard value.hasPrefix("ENCRYPTED:") else { return false }
        let encryptedPart = String(value.dropFirst("ENCRYPTED:".count))
        return decryptString(encryptedPart, using: legacyEncryptionKey) != nil
    }
    
    /// Decrypts a value using the legacy hardcoded key
    private func decryptWithLegacyKey(_ value: String) -> String? {
        guard value.hasPrefix("ENCRYPTED:") else { return nil }
        let encryptedPart = String(value.dropFirst("ENCRYPTED:".count))
        return decryptString(encryptedPart, using: legacyEncryptionKey)
    }
}
