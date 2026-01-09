//
//  AppUtils+Alerts.swift
//  WalletVault
//
//  Created by Gonçalo on 26/03/2024.
//

import SwiftUI

extension AppUtils {
    func requestCameraPermissionAlert() -> Alert {
        Alert(
            title: Text("Camera Permission Needed"),
            message: Text("Please allow camera access in your device settings to use the QR code scanner."),
            primaryButton: .cancel(Text("Not Now")),
            secondaryButton: .default(Text("Settings"), action: {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            })
        )
    }
    
    func requestDefaultErrorAlert(message: String? = nil) -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(message ?? "An error has occurred, please try again."),
            dismissButton: .default(Text("OK"))
        )
    }
    
    func requestCardAddedAlert() -> Alert {
        Alert(
            title: Text("Success"),
            message: Text("Card imported successfully."),
            dismissButton: .default(Text("OK"))
        )
    }
    
    func requestRemoveCardAlert(cancelAction: @escaping (() -> Void), deleteAction: @escaping (() -> Void)) -> Alert {
        Alert(
            title: Text("Delete Card"),
            message: Text("Are you sure you want to delete this card?"),
            primaryButton: .default(Text("Cancel"), action: cancelAction),
            secondaryButton: .destructive(Text("Delete"), action: deleteAction)
        )
    }
}
