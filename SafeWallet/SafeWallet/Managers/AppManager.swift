//
//  AppManager.swift
//  SafeWallet
//
//  Created by Gonçalo on 18/01/2024.
//

import Combine
import CoreData

class AppManager: ObservableObject {
    let actionManager: AppActionManager
    @Published private(set) var constants: AppConstants
    let utils: AppUtils
    @Published var notificationHandler: NotificationHandler
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.actionManager = AppActionManager(context: context)
        self.constants = AppConstants()
        self.utils = AppUtils()
        self.notificationHandler = NotificationHandler(context: context)
    }
}

class NotificationHandler: ObservableObject {
    @Published var selectedCardID: NSManagedObjectID?
    
    init(context: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NotificationCardID"), object: nil, queue: .main) { notification in
            if let cardIDString = notification.userInfo?["cardID"] as? String,
               let uri = URL(string: cardIDString),
               let coordinator = context.persistentStoreCoordinator,
               let cardID = coordinator.managedObjectID(forURIRepresentation: uri) {
                DispatchQueue.main.async {
                    self.selectedCardID = cardID
                }
            }
        }
    }
}


