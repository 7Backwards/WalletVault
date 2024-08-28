//
//  MyCardView.swift
//  SafeWallet
//
//  Created by Gonçalo on 08/01/2024.
//

import SwiftUI

struct MyCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject var viewModel: MyCardViewModel
    
    init(appManager: AppManager, cardObject: CardObservableObject) {
        self.viewModel = MyCardViewModel(cardObject: cardObject, appManager: appManager)
    }
    
    var body: some View {
        ZStack {
            VStack {
                CardDetailsView(appManager: viewModel.appManager, cardObject: viewModel.cardObject, isEditing: $viewModel.isEditable, isUnlocked: true) { isFavorited in
                    guard let id = viewModel.cardObject.id else { return }
                    viewModel.appManager.actionManager.doAction(action: .setIsFavorited(id: id, isFavorited)) { result in
                        if result {
                            viewModel.cardObject.isFavorited.toggle()
                        }
                    }
                }
                .frame(height: viewModel.appManager.constants.getCardHeight(sizeCategory: sizeCategory))
                
                if viewModel.isEditable {
                    ColorCarouselView(cardColor: $viewModel.cardObject.cardColor, appManager: viewModel.appManager)
                    AddButton(appManager: viewModel.appManager, cardObject: viewModel.cardObject, showAlert: { errorMessage in self.viewModel.activeAlert = .error(errorMessage) }, isEditable: $viewModel.isEditable)
                }
                
                Spacer()
                
                MyCardViewActionButtons(viewModel: viewModel)
                    .actionSheet(isPresented: $viewModel.showingShareSheet) {
                        ActionSheet(
                            title: Text("Share Card"),
                            message: Text("Choose how you would like to share the card"),
                            buttons: [
                                .default(Text("Share Inside App")) {
                                    viewModel.activeShareSheet = .insideShare
                                },
                                .default(Text("Share Outside App")) {
                                    viewModel.activeShareSheet = .outsideShare
                                },
                                .cancel()
                            ]
                        )
                    }
            }
        }
        .onAppear {
            viewModel.startAutoLockTimer()
        }
        .onDisappear {
            viewModel.invalidateAutoLockTimer()
            viewModel.updateCardColor(cardColor: viewModel.cardObject.cardColor)
        }
        .onChange(of: viewModel.shouldDismissView) { _, shouldDismiss in
            if shouldDismiss {
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        .navigationBarTitle(viewModel.cardObject.cardName, displayMode: .inline)
        .alert(item: $viewModel.activeAlert) { activeAlert in
            switch activeAlert {
            case .deleteConfirmation:
                viewModel.appManager.utils.requestRemoveCardAlert { 
                    self.viewModel.activeAlert = nil
                } deleteAction: { 
                    withAnimation {
                        viewModel.delete { result in
                            if result {
                                viewModel.shouldDismissView = true
                            } else {
                                Logger.log("Error deleting the card", level: .error)
                            }
                        }
                    }
                    self.viewModel.activeAlert = nil
                }
            case .error:
                viewModel.appManager.utils.requestDefaultErrorAlert()
            }
        }
        .sheet(item: $viewModel.activeShareSheet) { activeShareSheet in
            switch activeShareSheet {
            case .insideShare:
                VStack(spacing: 5) {
                    Text("Scan this QR Code when adding a new card")
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .dynamicTypeSize(.xSmall ... .xxxLarge)
                    QRCodeView(qrCodeImage: viewModel.appManager.utils.generateCardQRCode(from: viewModel.cardObject.getCardInfo()))
                        .frame(height: viewModel.appManager.constants.qrCodeHeight)
                        .padding()
                }
                .presentationDetents([.medium, .large])
                .padding()
            case .outsideShare:
                ShareUIActivityController(shareItems: [viewModel.appManager.utils.getFormattedShareCardInfo(card: viewModel.cardObject.getCardInfo())])
                    .presentationDetents([.medium, .large])
            }
        }
        .padding(.bottom, 20)
    }
}

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.black.opacity(0.5) : Color.black.opacity(0.9))
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
    }
}

struct MyCardViewActionButtons: View {
    @ObservedObject var viewModel: MyCardViewModel

    var body: some View {
        HStack(spacing: 30) {
            
            Button(action: {
                self.viewModel.showingShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.inverseSystemBackground)
            }
            .buttonStyle(RoundedButtonStyle())
            
            Button(action: {
                if viewModel.isEditable {
                    viewModel.undo()
                } else {
                    viewModel.saveCurrentCard()
                }
                viewModel.isEditable.toggle()
            }) {
                
                Image(systemName: viewModel.isEditable ? "arrow.uturn.backward.circle.fill" : "pencil.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.inverseSystemBackground)
                
            }
            .buttonStyle(RoundedButtonStyle())
            
            Button(action: {
                viewModel.activeAlert = .deleteConfirmation
            }) {
                Image(systemName: "trash.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.inverseSystemBackground)
            }
            .buttonStyle(RoundedButtonStyle())
        }
        .padding(.horizontal, 20)
    }
}


struct MyCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock Card object for the preview
        let mockCard = Card(context: PersistenceController.preview.container.viewContext)
        mockCard.cardName = "Visa"
        mockCard.cardNumber = "4234 5678 9012 3456"
        mockCard.expiryDate = "12/25"
        mockCard.cvvCode = "123"

        return MyCardView(appManager: AppManager(context: PersistenceController.preview.container.viewContext), cardObject: CardObservableObject(card: mockCard))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

