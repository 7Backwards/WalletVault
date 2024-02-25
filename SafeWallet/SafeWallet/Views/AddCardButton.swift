//
//  AddCardButton.swift
//  SafeWallet
//
//  Created by Gonçalo on 11/02/2024.
//

import Foundation
import SwiftUI
import CoreData

struct AddButton: View {
    let viewModel: AddCardButtonViewModel
    var presentationMode: Binding<PresentationMode>?
    
    init(appManager: AppManager, cardObject: CardObservableObject, showAlert: @escaping (String) -> Void, presentationMode: Binding<PresentationMode>? = nil, isEditable: Binding<Bool>) {
        self.viewModel = AddCardButtonViewModel(appManager: appManager, cardObject: cardObject, isEditable: isEditable, showAlert: showAlert)
        self.presentationMode = presentationMode
    }
    
    var body: some View {
        GeometryReader { geometry in
            Button("Save Card") {
                var alertMessage = ""
                viewModel.addOrEdit(cardObject: viewModel.cardObject) { result in
                    switch result {
                    case .success:
                        if let presentationMode {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            viewModel.isEditable = false
                        }
                    case .failure(let error):
                        switch error {
                        case .invalidDate:
                            alertMessage = "Invalid expiration date, please update it."
                        case .savingError:
                            alertMessage = "Something went wrong, please try again."
                        case .shortCardNumber:
                            alertMessage = "Card number is not invalid, please update it."
                        }
                        viewModel.showAlert(alertMessage)
                    }
                }
            }
            .frame(width: geometry.size.width - 60, height: 50)
            .background(.blue)
            .foregroundColor(Color(.systemBackground))
            .cornerRadius(10)
            .padding(.leading, 30)
        }
    }
}
