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

class AddCardViewModel: ViewModelProtocol {
    @Published var selectedColor: Color?
    @Published var appManager: AppManager
    
    init(appManager: AppManager) {
        self.appManager = appManager
    }
    
    func addCard(cardName: String, cardNumber: String, expiryDate: String, cvvCode: String, cardColor: String, completion: @escaping (Result<Void, AddCardErrorType>) -> Void) {
        guard !cardName.isEmpty, !cardNumber.isEmpty, !expiryDate.isEmpty, !cvvCode.isEmpty, !cardColor.isEmpty else { return }
        
        if cardNumber.count != 16 {
            completion(.failure(.shortCardNumber))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.isLenient = false

        if let date = dateFormatter.date(from: expiryDate) {
            if Calendar.current.compare(date, to: Date(), toGranularity: .month) == .orderedDescending {
                appManager.actionManager.doAction(action: .addCard(cardName: cardName, cardNumber: cardNumber, expiryDate: expiryDate, cvvCode: cvvCode, cardColor: cardColor)) { result in
                    completion(result ? .success(()) : .failure(.savingError))
                }
            } else {
                completion(.failure(.invalidDate))
                print("The expiry date must be later than the current date.")
            }
        } else {
            completion(.failure(.invalidDate))
            print("Invalid date format. Please enter the expiry date in mm/yy format.")
        }
    }
}

