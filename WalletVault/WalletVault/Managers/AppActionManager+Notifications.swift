//
//  AppActionManager+Notifications.swift
//  WalletVault
//
//  Created by Gonçalo on 03/03/2024.
//

import Foundation
import UserNotifications
import CoreData

func scheduleCardNotifications(cardID: NSManagedObjectID, cardName: String, expiryDate: String) {
    let notificationCenter = UNUserNotificationCenter.current()
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/yy"
    
    // Convert expiryDateStr to Date
    guard let expiryDate = dateFormatter.date(from: expiryDate) else {
        Logger.log("Invalid expiry date format", level: .error)
        return
    }
    
    removeCardNotifications(cardID: cardID)
    
    // Calculate the last day of the expiry month
    var dateComponents = DateComponents(year: calendar.component(.year, from: expiryDate), month: calendar.component(.month, from: expiryDate) + 1)
    dateComponents.second = -1 // One second before the next month begins
    guard let lastDayOfMonth = calendar.date(from: dateComponents) else { return }
    
    // Calculate the date for 3-months prior notification
    guard let threeMonthsBeforeExpiry = calendar.date(byAdding: .month, value: -3, to: lastDayOfMonth) else { return }
    
    // Schedule the 3-months prior notification
    scheduleNotification(notificationCenter: notificationCenter, cardID: cardID, cardName: cardName, triggerDate: threeMonthsBeforeExpiry, identifierSuffix: "3Months", title: "Card Expiry Reminder!", body: "Your \(cardName) is expiring in 3 months.")
    
    // Calculate the date for expired notification (one day after the last day of the expiry month)
    let oneDayAfterExpiry = calendar.date(byAdding: .day, value: 1, to: lastDayOfMonth)!
    
    // Schedule the expired notification
    scheduleNotification(notificationCenter: notificationCenter, cardID: cardID, cardName: cardName, triggerDate: oneDayAfterExpiry, identifierSuffix: "Expired", title: "Card Expired!", body: "Your \(cardName) has now expired.")
}

func removeCardNotifications(cardID: NSManagedObjectID) {
    let notificationCenter = UNUserNotificationCenter.current()
    
    let threeMonthsIdentifier = "\(cardID.uriRepresentation().lastPathComponent)-3Months"
    let expiredIdentifier = "\(cardID.uriRepresentation().lastPathComponent)-Expired"
    
    notificationCenter.removePendingNotificationRequests(withIdentifiers: [threeMonthsIdentifier, expiredIdentifier])
}

private func scheduleNotification(notificationCenter: UNUserNotificationCenter, cardID: NSManagedObjectID, cardName: String, triggerDate: Date, identifierSuffix: String, title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    
    // Convert the NSManagedObjectID to a string
    let cardIDString = cardID.uriRepresentation().absoluteString
    // Add it to the userInfo dictionary
    content.userInfo = ["cardID": cardIDString]
    
    let calendar = Calendar.current
    let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
    
    let identifier = "\(cardID.uriRepresentation().lastPathComponent)-\(identifierSuffix)"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    
    notificationCenter.add(request) { error in
        if let error = error {
            Logger.log("Error scheduling \(identifierSuffix.lowercased()) notification: \(error.localizedDescription)", level: .error)
        }
    }
}


