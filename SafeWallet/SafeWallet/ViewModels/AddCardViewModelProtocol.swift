//
//  AddCardViewModelProtocol.swift
//  SafeWallet
//
//  Created by Gonçalo on 11/02/2024.
//

import Foundation
import CoreData

protocol AddOrEditCardViewModelProtocol {
    func addOrEdit(id: NSManagedObjectID?, cardName: String, cardNumber: String, expiryDate: String, cvvCode: String, cardColor: String, completion: @escaping (Result<Void, AddCardErrorType>) -> Void)
}

class AddOrEditCardViewModel: AddOrEditCardViewModelProtocol {
    @Published var appManager: AppManager

    init(appManager: AppManager) {
        self.appManager = appManager
    }

    func addOrEdit(id: NSManagedObjectID?, cardName: String, cardNumber: String, expiryDate: String, cvvCode: String, cardColor: String, completion: @escaping (Result<Void, AddCardErrorType>) -> Void) {
        guard !cardName.isEmpty, !cardNumber.isEmpty, !expiryDate.isEmpty, !cvvCode.isEmpty, !cardColor.isEmpty else { return }
        
        if cardNumber.count != 19 {
            completion(.failure(.shortCardNumber))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.isLenient = false

        if let date = dateFormatter.date(from: expiryDate) {
            if Calendar.current.compare(date, to: Date(), toGranularity: .month) == .orderedDescending {
                if let id {
                    appManager.actionManager.doAction(action: .editCard(id: id, cardName: cardName, cardNumber: cardNumber, expiryDate: expiryDate, cvvCode: cvvCode, cardColor: cardColor)) { result in
                        completion(result ? .success(()) : .failure(.savingError))
                    }
                } else {
                    appManager.actionManager.doAction(action: .addCard(cardName: cardName, cardNumber: cardNumber, expiryDate: expiryDate, cvvCode: cvvCode, cardColor: cardColor)) { result in
                        completion(result ? .success(()) : .failure(.savingError))
                    }
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
