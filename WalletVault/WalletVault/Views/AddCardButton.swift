//
//  AddCardButton.swift
//  WalletVault
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
        Button(action: {
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
                        alertMessage = "Card number is invalid, please update it."
                    }
                    viewModel.showAlert(alertMessage)
                }
            }
        }) {
            Text("Save Card")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxHeight: 50)
        .dynamicTypeSize(.xSmall ... .xxxLarge)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.blue.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
        .accessibilityIdentifier("saveButton")
    }
}
