//
//  WalletVaultApp.swift
//  WalletVault
//
//  Created by Gonçalo on 21/12/2023.
//

import SwiftUI
import CoreData

@main
struct WalletVaultApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let appManager: AppManager
    let viewContext: NSManagedObjectContext

    init() {
        self.viewContext = PersistenceController.shared.container.viewContext
        self.appManager = AppManager(context: viewContext)
    }

    var body: some Scene {
        WindowGroup {
            CardListView(viewModel: CardListViewModel(appManager: appManager))
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
