//
//  MockBiometricAuth.swift
//  WalletVaultTests
//
//  Created by Gonçalo on 24/03/2024.
//

@testable import WalletVault
import LocalAuthentication

class MockBiometricAuth: BiometricAuthenticating {
    var shouldEvaluatePolicy = true
    var evaluationError: NSError?
    var error: AuthenticationError?
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        if let evaluationError {
            error?.pointee = evaluationError
        }
        return shouldEvaluatePolicy
    }
    
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
        if let error {
            reply(false, error)
        } else {
            reply(shouldEvaluatePolicy, evaluationError)
        }
    }
}

enum AuthenticationError: Error, Equatable {
    case biometricUnavailable
    case biometricLockout
    case biometricNotEnrolled
    case fallback
    case other

    var localizedDescription: String {
        switch self {
        case .biometricUnavailable:
            return "Biometric authentication is currently unavailable."
        case .biometricLockout:
            return "Biometric authentication is locked due to too many attempts."
        case .biometricNotEnrolled:
            return "Biometric features are not enrolled on this device."
        case .fallback:
            return "User chose to use fallback authentication method."
        case .other:
            return "An unknown error occurred during authentication."
        }
    }
}
