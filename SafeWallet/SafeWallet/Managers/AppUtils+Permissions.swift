//
//  AppUtils+Permissions.swift
//  SafeWallet
//
//  Created by Gonçalo on 26/03/2024.
//

import SwiftUI
import UserNotifications
import AVFoundation

extension AppUtils {
    func checkCameraPermission(completion: (_ isCameraPermissionsGranted: Bool, _ showAlert: Bool) -> Void) {
        var isCameraPermissionsGranted = false
        var showAlert = false

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraPermissionsGranted = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    isCameraPermissionsGranted = granted
                    if !granted {
                        showAlert = true
                    }
                }
            }
            
        case .denied, .restricted:
            isCameraPermissionsGranted = false
            showAlert = true
            
        default:
            break
        }
        
        completion(isCameraPermissionsGranted, showAlert)
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
