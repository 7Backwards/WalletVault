//
//  AddCardView.swift
//  WalletVault
//
//  Created by Gonçalo on 22/12/2023.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddCardViewModel
    @Environment(\.sizeCategory) var sizeCategory
    @State var isColorPickerPresented = false
    
    init(appManager: AppManager) {
        self.viewModel = AddCardViewModel(appManager: appManager)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.systemBackground,
                        Color.systemBackground.opacity(0.97)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    ZStack {
                        if isColorPickerPresented {
                            CustomColorPicker(onCancel: { isColorPickerPresented = false }, onSelect: { newColor in
                                guard let hex = newColor.toHex() else { return }
                                viewModel.appManager.actionManager.doAction(action: .insertNewColor(hexValue: hex, isDefault: false))
                                isColorPickerPresented = false
                            })
                            .padding(16)
                            .transition(.opacity.combined(with: .scale))
                        } else {
                            VStack(spacing: 20) {
                                CardDetailsView(appManager: viewModel.appManager, cardObject: viewModel.cardObject, isEditing: $viewModel.isEditable, isUnlocked: true) { isFavorited in
                                    guard let id = viewModel.cardObject.id else { return }
                                    viewModel.appManager.actionManager.doAction(action: .setIsFavorited(id: id, isFavorited)) { result in
                                        if result {
                                            viewModel.cardObject.isFavorited.toggle()
                                        }
                                    }
                                }
                                .padding(.horizontal, -16)
                                .transition(.opacity)

                                ColorCarouselView(cardColor: $viewModel.cardObject.cardColor, isColorPickerPresented: $isColorPickerPresented, appManager: viewModel.appManager)
                                    .padding(.horizontal, -8)
                                    .transition(.opacity)

                                AddButton(appManager: viewModel.appManager, cardObject: viewModel.cardObject, showAlert: { alertMessage in viewModel.activeAlert = .error(alertMessage) }, presentationMode: presentationMode, isEditable: $viewModel.isEditable)
                                    .transition(.opacity)
                            }
                            .padding(16)
                            .transition(.opacity)
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                    .padding(16)
                }
            }
        }
        .alert(item: $viewModel.activeAlert) { alert in
            switch alert {
            case .error(let errorMessage):
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
