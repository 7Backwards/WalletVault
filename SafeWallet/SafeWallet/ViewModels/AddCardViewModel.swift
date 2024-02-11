//
//  AddCardViewModel.swift
//  SafeWallet
//
//  Created by Gonçalo on 23/12/2023.
//

import Foundation
import CoreData
import SwiftUI

enum AddCardErrorType: Error {
    case invalidDate
    case savingError
    case shortCardNumber
}

class AddCardViewModel: AddOrEditCardViewModel, ViewModelProtocol {
    @Published var selectedColor: Color?
}
