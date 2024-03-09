//
//  AppDelegate.swift
//  SafeWallet
//
//  Created by Gonçalo on 03/03/2024.
//

import UIKit
import CoreData
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            Logger.log("Permission granted: \(granted)")
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // Handle notifications when app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle the notification action
        if let cardID = userInfo["cardID"] as? String {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("NotificationCardID"), object: nil, userInfo: ["cardID": cardID])
            }
        }
        
        completionHandler()
    }
}
