//
//  AddCardViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 23/12/2023.
//

import Foundation
import CoreData
import SwiftUI

class AddCardViewModel: AddOrEditMyCardViewModel, ViewModelProtocol {
    @Published var selectedColor: Color?
    @Published var cardObject = CardObservableObject(card: nil)
    @Published var isEditable: Bool = true
    @Published var activeAlert: ActiveAlert?
    
    enum ActiveAlert: Identifiable {
        case deleteConfirmation
        case error(String)
        
        var id: String {
            switch self {
            case .deleteConfirmation:
                return "deleteConfirmation"
            case .error(let errorMessage):
                return errorMessage
            }
        }
    }
}
