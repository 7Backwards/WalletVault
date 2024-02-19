//
//  AddCardView.swift
//  SafeWallet
//
//  Created by Gonçalo on 22/12/2023.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var cardViewModel = CardViewModel(card: nil)
    @State private var activeAlert: AppUtils.ActiveAlert?
    @State var isEditable: Bool = true
    @StateObject var viewModel: AddCardViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                CardDetailsView(
                    viewModel: CardDetailsViewModel(appManager: viewModel.appManager),
                    cardViewModel: cardViewModel,
                    isEditable: $isEditable,
                    isUnlocked: true) { isFavorited in
                        guard let id = cardViewModel.id else { return }
                        viewModel.appManager.actionManager.doAction(action: .setIsFavorited(id: id, isFavorited)) { result in
                            if result {
                                cardViewModel.isFavorited.toggle()
                            }
                        }
                    }
                .frame(height: viewModel.appManager.constants.cardHeight)
                
                ColorCarouselView(cardColor: $cardViewModel.cardColor, viewModel: ColorCarouselViewModel(appManager: viewModel.appManager))

                AddButton(viewModel: viewModel, cardViewModel: cardViewModel, isEditable: $isEditable, showAlert: { alertMessage in activeAlert = .error(alertMessage) }, presentationMode: presentationMode)
            }
        }
        .navigationBarTitle("Add Card", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
        })
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .error(let errorMessage) :
                return Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
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
        AddCardView(viewModel: AddCardViewModel(appManager: AppManager(context: context)))
    }
}
