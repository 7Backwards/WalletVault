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
        
        var id: String {
            switch self {
            case .cardAdded:
                return "cardAdded"
            case .error:
                return "error"
            }
        }
    }
    
    func deleteCards(at offsets: IndexSet, from cards: FetchedResults<Card>) {
        withAnimation {
            let cardsToDelete = offsets.map { cards[$0] }
            appManager.actionManager.doAction(action: .removeCards(cardsToDelete))
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
