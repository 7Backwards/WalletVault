//
//  AddCardView.swift
//  SafeWallet
//
//  Created by Gonçalo on 22/12/2023.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var cardName: String = ""
    @State private var cardNumber: String = ""
    @State private var expiryDate: String = ""
    @State private var cvvCode: String = ""
    @State private var cardColor: String = Color.ColorName.systemBackground.rawValue
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State var isEditable: Bool = true
    @StateObject var viewModel: AddCardViewModel
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 30) {
                        CardDetailsView(
                                        viewModel: CardDetailsViewModel(appManager: viewModel.appManager),
                                        cardName: $cardName,
                                        cardNumber: $cardNumber,
                                        expiryDate: $expiryDate,
                                        cvvCode: $cvvCode,
                                        cardColor: $cardColor,
                                        isEditable: $isEditable,
                                        isUnlocked: .constant(true))
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        
                        ColorCarouselView(cardColor: $cardColor, viewModel: ColorCarouselViewModel(appManager: viewModel.appManager))
                        
                        AddButton(viewModel: viewModel, cardName: $cardName, cardNumber: $cardNumber, expiryDate: $expiryDate, cvvCode: $cvvCode, cardColor: $cardColor, alertMessage: $alertMessage, showAlert: $showAlert, isEditable: $isEditable, presentationMode: presentationMode)
                    }
                }
            }
            .navigationBarTitle("Add Card", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
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
