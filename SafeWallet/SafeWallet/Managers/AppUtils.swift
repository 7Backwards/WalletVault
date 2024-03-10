//
//  AppUtils.swift
//  SafeWallet
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI
import UserNotifications

class AppUtils {
    private var protectWindow = PrivacyProtectionWindow()
    
    func getFormattedShareCardInfo(card: CardInfo) -> String {
        var info = "\(NSLocalizedString("Card Name", comment: "")): \(card.cardName) \n\(NSLocalizedString("Card Number", comment: "")): \(card.cardNumber) \n\(NSLocalizedString("Expiry Date", comment: "")): \(card.expiryDate) \n\(NSLocalizedString("CVV", comment: "")): \(card.cvvCode) \n"
        
        if !card.pin.isEmpty {
            info.append("\(NSLocalizedString("Card Pin", comment: "")): \(card.pin)")
        }
        
        return info
    }
    
    func getNonFormattedShareCardInfo(card: CardInfo) -> String {
        "\(card.cardName),\(card.cardNumber),\(card.expiryDate), \(card.cvvCode), \(card.pin)"
    }
    
    func parseCardInfo(from shareableString: String) -> CardInfo? {
        let components = shareableString.components(separatedBy: ",")
        guard components.count >= 5 else { return nil }
        
        let cardName = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let cardNumber = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let expiryDate = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
        let cvvCode = components[3].trimmingCharacters(in: .whitespacesAndNewlines)
        let pin = components[4].trimmingCharacters(in: .whitespacesAndNewlines)

        return CardInfo(
            cardName: cardName,
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cvvCode: cvvCode,
            pin: pin
        )
    }


    func protectScreen() {
        protectWindow.startProtection()
    }

    func unprotectScreen() {
        protectWindow.stopProtection()
    }

    func formatCardNumber(_ number: String) -> String {
        // First, filter out any non-numeric characters
        let filtered = number.filter { "0123456789".contains($0) }
        
        // Then, limit to the first 16 characters
        let trimmed = String(filtered.prefix(16))
        
        // Finally, add a space after every 4 digits
        return stride(from: 0, to: trimmed.count, by: 4).map {
            let start = trimmed.index(trimmed.startIndex, offsetBy: $0)
            let end = trimmed.index(start, offsetBy: 4, limitedBy: trimmed.endIndex) ?? trimmed.endIndex
            return String(trimmed[start..<end])
        }.joined(separator: " ")
    }
    
    func getCardIssuerImage(cardNumber: String) -> Image? {
        let formattedNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        
        if formattedNumber.hasPrefix("4") {
            return Image("visa")
        } else if formattedNumber.range(of: "^(51|52|53|54|55|2221|222[2-9]|22[3-9]\\d|2[3-6]\\d\\d|27[01]\\d|2720)", options: .regularExpression) != nil {
            return Image("mastercard")
        } else if formattedNumber.range(of: "^(34|37)", options: .regularExpression) != nil {
            return Image("american-express")
        } else {
            return nil
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                Logger.log("Notification permission granted.")
            } else if let error = error {
                Logger.log("Notification permission denied because: \(error.localizedDescription).", level: .error)
            }
        }
    }
}

class PrivacyProtectionWindow {
    private var window: UIWindow?

    func startProtection() {
        NotificationCenter.default.addObserver(self, selector: #selector(protect), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(protect), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unprotect), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func protect() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ProtectScreenViewController()
        window?.windowLevel = .alert + 1
        window?.backgroundColor = .systemBackground
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Logger.log("Protecting screen on app switcher")
            self.window?.makeKeyAndVisible()
        }
    }

    @objc func unprotect() {
        Logger.log("Unprotecting screen on app switcher")
        window?.isHidden = true
        window?.resignKey()
        window = nil
    }

    func stopProtection() {
        unprotect()
        NotificationCenter.default.removeObserver(self)
    }
}
