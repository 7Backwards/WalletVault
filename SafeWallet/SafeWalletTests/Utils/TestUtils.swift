//
//  Utils.swift
//  SafeWalletTests
//
//  Created by Gonçalo on 10/03/2024.
//

@testable import SafeWallet
import Foundation
import CoreData


class TestUtils {
    static func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        guard let modelURL = Bundle.main.url(forResource: "SafeWallet", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Model not found")
        }

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            fatalError("Adding in-memory persistent store failed: \(error)")
        }

        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }
}
