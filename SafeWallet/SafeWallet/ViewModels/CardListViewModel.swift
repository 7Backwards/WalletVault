//
//  CardListViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 23/12/2023.
//

import Foundation
import CoreData
import SwiftUI

class CardListViewModel: AddOrEditMyCardViewModel, ViewModelProtocol {
    @Published var searchText = ""
    @Published var activeShareSheet: ActiveShareSheet?
    @Published var activeAlert: ActiveAlert?
    @Published var isShowingErrorMessage: Bool = false
    private var cardsViewModels = [NSManagedObjectID : CardObservableObject]()
    
    enum ActiveShareSheet: Identifiable {
        case addCard
        case scanQRCode
        
        var id: String {
            switch self {
            case .addCard:
                return "addCard"
            case .scanQRCode:
                return "scanQRCode"
            }
        }
    }
    
    enum ActiveAlert: Identifiable {
        case cardAdded
        case error
        case removeCard(NSManagedObjectID)
        
        var id: String {
            switch self {
            case .cardAdded:
                return "cardAdded"
            case .removeCard:
                return "removeCard"
            case .error:
                return "error"
            }
        }
    }
    
    func deleteCard(id: NSManagedObjectID, from cards: FetchedResults<Card>) {
        withAnimation {
            appManager.actionManager.doAction(action: .removeCard(id))
        }
    }
    
    func authenticate(completion: @escaping (Bool) -> Void) {
        BiometricManager().authenticateUser { result in
            if let result = try? result.get(), result {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getCardObservableObject(for card: Card) -> CardObservableObject {
        if let viewModel = cardsViewModels[card.objectID] {
            return viewModel
        } else {
            let viewModel = CardObservableObject(card: card)
            cardsViewModels[card.objectID] = viewModel
            return viewModel
        }
    }
}
