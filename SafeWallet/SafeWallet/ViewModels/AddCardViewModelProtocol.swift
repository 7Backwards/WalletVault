//
//  AddMyCardViewModelProtocol.swift
//  SafeWallet
//
//  Created by Gonçalo on 11/02/2024.
//

import Foundation
import Combine
import CoreData

protocol AddOrEditMyCardViewModelProtocol {
    func addOrEdit(cardObject: CardObservableObject, completion: @escaping (Result<Void, AddCardErrorType>) -> Void)
}

class AddOrEditMyCardViewModel: AddOrEditMyCardViewModelProtocol {
    @Published var appManager: AppManager

    init(appManager: AppManager) {
        self.appManager = appManager
    }

    func addOrEdit(cardObject: CardObservableObject, completion: @escaping (Result<Void, AddCardErrorType>) -> Void) {
        let cardName = cardObject.cardName
        let cardNumber = cardObject.cardNumber
        let cardColor = cardObject.cardColor
        let cvvCode = cardObject.cvvCode
        let isFavorited = cardObject.isFavorited
        let expiryDate = cardObject.expiryDate
        let id = cardObject.id
        let pin = cardObject.pin

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
                    appManager.actionManager.doAction(action: .editCard(id: id, cardName: cardName, cardNumber: cardNumber, expiryDate: expiryDate, cvvCode: cvvCode, cardColor: cardColor, isFavorited: isFavorited, pin: pin)) { result in
                        completion(result ? .success(()) : .failure(.savingError))
                    }
                } else {
                    appManager.actionManager.doAction(action: .addCard(cardName: cardName, cardNumber: cardNumber, expiryDate: expiryDate, cvvCode: cvvCode, cardColor: cardColor, isFavorited: isFavorited, pin: pin)) { result in
                        completion(result ? .success(()) : .failure(.savingError))
                    }
                }
            } else {
                completion(.failure(.invalidDate))
                Logger.log("The expiry date must be later than the current date.", level: .error)
            }
        } else {
            completion(.failure(.invalidDate))
            Logger.log("Invalid date format. Please enter the expiry date in mm/yy format.", level: .error)
        }
    }
}
