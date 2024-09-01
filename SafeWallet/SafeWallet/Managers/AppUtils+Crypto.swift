//
//  AppUtils+Crypto.swift
//  SafeWallet
//
//  Created by Gonçalo on 29/08/2024.
//

import Foundation
import CryptoKit

extension AppUtils {
    // Encrypt a string
    func encryptString(_ string: String?, using key: SymmetricKey) -> String? {
        guard let string else { return nil }
        let data = Data(string.utf8)
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            let combined = sealedBox.combined!
            return combined.base64EncodedString()
        } catch {
            print("Failed to encrypt: \(error)")
            return nil
        }
    }
    
    // Decrypt a string
    func decryptString(_ base64String: String?, using key: SymmetricKey) -> String? {
        guard let base64String, let data = Data(base64Encoded: base64String) else { return nil }
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Failed to decrypt: \(error)")
            return nil
        }
    }
    
}
