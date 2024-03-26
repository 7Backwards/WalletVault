//
//  AddCardView.swift
//  SafeWallet
//
//  Created by Gonçalo on 22/12/2023.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddCardViewModel
    @Environment(\.sizeCategory) var sizeCategory
    
    init(appManager: AppManager) {
        self.viewModel = AddCardViewModel(appManager: appManager)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                CardDetailsView(appManager: viewModel.appManager, cardObject: viewModel.cardObject, isEditing: $viewModel.isEditable, isUnlocked: true) { isFavorited in
                        guard let id = viewModel.cardObject.id else { return }
                        viewModel.appManager.actionManager.doAction(action: .setIsFavorited(id: id, isFavorited)) { result in
                            if result {
                                viewModel.cardObject.isFavorited.toggle()
                            }
                        }
                    }
                .frame(height: viewModel.appManager.constants.getCardHeight(sizeCategory: sizeCategory))
                
                ColorCarouselView(cardColor: $viewModel.cardObject.cardColor, appManager: viewModel.appManager)

                AddButton(appManager: viewModel.appManager, cardObject: viewModel.cardObject, showAlert: { alertMessage in viewModel.activeAlert = .error(alertMessage) }, presentationMode: presentationMode, isEditable: $viewModel.isEditable)
            }
            .padding(.vertical, 5)
        }
        .navigationBarTitle("Add Card", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
        })
        .alert(item: $viewModel.activeAlert) { alert in
            switch alert {
            case .error(let errorMessage) :
                return viewModel.appManager.utils.requestDefaultErrorAlert(message: errorMessage)
            default:
                return Alert(title: Text(""))
            }
        }
    }
}

// A placeholder Card object for preview purposes
extension Card {
    static var placeholder: Card {
        let card = Card(context: PersistenceController.preview.container.viewContext)
        card.cardName = "Card Name"
        card.cardNumber = "Card Number"
        card.expiryDate = "MM/YY"
        card.cvvCode = "CVV"
        return card
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        AddCardView(appManager: AppManager(context: context))
    }
}
