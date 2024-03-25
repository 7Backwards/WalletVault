//
//  BiometricManager.swift
//  SafeWallet
//
//  Created by Gonçalo on 28/12/2023.
//

import LocalAuthentication

protocol BiometricAuthenticating {
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void)
}

extension LAContext: BiometricAuthenticating {}

class BiometricManager {
    let context: BiometricAuthenticating
    var loginReason = NSLocalizedString("Protection with Face ID", comment: "")
    
    init(context: BiometricAuthenticating = LAContext()) {
        self.context = context
    }
    
    enum AuthenticationError: Error {
        case biometricUnavailable, biometricLockout, biometricNotEnrolled, fallback, other
    }
    
    func authenticateUser(completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            Logger.log("Biometrics unavailable", level: .error)
            completion(.failure(.biometricUnavailable))
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: loginReason) { success, evaluateError in
            DispatchQueue.main.async {
                if success {
                    Logger.log("Biometric authentication successfull")
                    completion(.success(true))
                } else {
                    Logger.log("Biometric authentication error \(String(describing: evaluateError))", level: .error)
                    if let error = evaluateError as NSError? {
                        switch error.code {
                        case LAError.authenticationFailed.rawValue:
                            completion(.failure(.other))
                        case LAError.userCancel.rawValue, LAError.userFallback.rawValue:
                            completion(.failure(.fallback))
                        case LAError.biometryNotAvailable.rawValue:
                            completion(.failure(.biometricUnavailable))
                        case LAError.biometryNotEnrolled.rawValue:
                            completion(.failure(.biometricNotEnrolled))
                        case LAError.biometryLockout.rawValue:
                            completion(.failure(.biometricLockout))
                        default:
                            // Something went wrong with the authentication
                            completion(.failure(.other))
                        }
                    }
                }
            }
        }
    }
}
