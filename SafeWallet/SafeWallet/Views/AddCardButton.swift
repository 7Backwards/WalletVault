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
    let viewModel: AddOrEditMyCardViewModelProtocol
    @ObservedObject var cardViewModel: CardViewModel
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    @Binding var isEditable: Bool
    var presentationMode: Binding<PresentationMode>?
    
    var body: some View {
        GeometryReader { geometry in
            Button("Save Card") {
                viewModel.addOrEdit(cardViewModel: cardViewModel) { result in
                    switch result {
                    case .success:
                        if let presentationMode {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            isEditable = false
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
                        showAlert = true
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
