//
//  AppManager.swift
//  WalletVault
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
        self.utils = AppUtils()
        self.actionManager = AppActionManager(context: context, appUtils: self.utils)
        self.constants = AppConstants()
        self.notificationHandler = NotificationHandler(context: context)
        
        // Set reference so utils can access encryption key
        self.utils.appManager = self
        // Set reference so actionManager can encrypt/decrypt
        self.actionManager.appUtils = self.utils
        
        // Force encryption key initialization from Keychain
        _ = constants.encryptionKey
        Logger.log("Encryption key initialized from Keychain")
        
        actionManager.setupDefaultColors(colors: constants.defaultColors)
        
        // Perform one-time migration to encrypt existing plaintext cards
        utils.migrateExistingCards(in: context)
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


