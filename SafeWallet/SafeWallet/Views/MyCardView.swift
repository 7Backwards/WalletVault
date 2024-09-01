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
    @State var isColorPickerPresented = false
    
    init(appManager: AppManager, cardObject: CardObservableObject) {
        self.viewModel = MyCardViewModel(cardObject: cardObject, appManager: appManager)
    }
    
    var body: some View {
        ZStack {
            if isColorPickerPresented {
                CustomColorPicker(onCancel: { isColorPickerPresented = false }, onSelect: { newColor in
                    guard let hex = newColor.toHex() else { return }
                    viewModel.appManager.actionManager.doAction(action: .insertNewColor(hexValue: hex, isDefault: false))
                    isColorPickerPresented = false 
                })
                .padding()
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
                    
                    if viewModel.isEditable {
                        ColorCarouselView(cardColor: $viewModel.cardObject.cardColor, isColorPickerPresented: $isColorPickerPresented, appManager: viewModel.appManager)
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
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            viewModel.startAutoLockTimer()
        }
        .onDisappear {
            viewModel.invalidateAutoLockTimer()
            if let cardColor = viewModel.cardObject.cardColor { 
                viewModel.updateCardColor(cardColor: cardColor)
            }
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
                VStack(spacing: 15) {
                    Text("Scan this QR Code to add a new card")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(2)
                    
                    if let code = viewModel.appManager.utils.getShareCardCode(card: viewModel.cardObject.getCardInfo(), key: viewModel.appManager.constants.encryptionKey) {
                        QRCodeView(qrCodeImage: viewModel.appManager.utils.generateCardQRCode(from: code))
                            .frame(height: viewModel.appManager.constants.qrCodeSize.height)
                            .padding()
                        
                        VStack(spacing: 10) {
                            Text("Or use this code:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(code)
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .padding(.trailing, 5)
                                
                                Button(action: {
                                    UIPasteboard.general.string = code
                                    print("Code copied to clipboard")
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                    } else {
                        Text("Error generating QR Code")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 10)
                .presentationDetents([.height(560)])
                .presentationDragIndicator(.visible)
                .padding(.horizontal)
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

