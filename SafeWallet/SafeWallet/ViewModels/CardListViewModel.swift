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
    private var cardsViewModels = [NSManagedObjectID : CardViewModel]()
    
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
    
    func deleteCards(id: NSManagedObjectID, from cards: FetchedResults<Card>) {
        if let index = cards.firstIndex(where: { $0.objectID == id }) {
            print("Deleting card")

            withAnimation {
                let cardsToDelete = IndexSet(integer: index).map { cards[$0] }
                appManager.actionManager.doAction(action: .removeCards(cardsToDelete))
            }
        } else {
            print("Failed to find index for card")
        }
    }
    
    func authenticate(completion: @escaping (Bool) -> Void) {
        BiometricAuth().authenticateUser { result in
            if let result = try? result.get(), result {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getCardViewModel(for card: Card) -> CardViewModel {
        if let viewModel = cardsViewModels[card.objectID] {
            return viewModel
        } else {
            let viewModel = CardViewModel(card: card)
            cardsViewModels[card.objectID] = viewModel
            return viewModel
        }
    }
}
