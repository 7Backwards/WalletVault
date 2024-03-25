//
//  BiometricManagerTests.swift
//  SafeWalletTests
//
//  Created by Gonçalo on 24/03/2024.
//

import XCTest
@testable import SafeWallet
import LocalAuthentication

class BiometricManagerTests: XCTestCase {
    var biometricAuth: BiometricManager!
    var mockContext: MockBiometricAuth!
    
    override func setUp() {
        super.setUp()
        mockContext = MockBiometricAuth()
        biometricAuth = BiometricManager(context: mockContext)
    }
    
    override func tearDown() {
        biometricAuth = nil
        mockContext = nil
        super.tearDown()
    }
    
    func testAuthenticateUserSuccess() {
        mockContext.shouldEvaluatePolicy = true
        let expectation = self.expectation(description: "BiometricAuthSuccess")
        
        biometricAuth.authenticateUser { result in
            if case .success(let success) = result {
                XCTAssertTrue(success)
            } else {
                XCTFail("Authentication was not successful")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testAuthenticateUserFailure() {
        // Set the error for biometric unavailable
        mockContext.shouldEvaluatePolicy = false
        let mockError = NSError(domain: LAErrorDomain, code: LAError.biometryNotAvailable.rawValue, userInfo: nil)
        mockContext.evaluationError = mockError

        let expectation = self.expectation(description: "BiometricAuthFailure")

        biometricAuth.authenticateUser { result in
            if case .failure(let error) = result {
                // Assert the specific error
                XCTAssertEqual(error, .biometricUnavailable)
            } else {
                XCTFail("Authentication should have failed with biometricUnavailable error")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
