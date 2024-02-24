//
//  MyCardView.swift
//  SafeWallet
//
//  Created by Gonçalo on 08/01/2024.
//

import SwiftUI

struct MyCardView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: MyCardViewModel
    @ObservedObject var cardViewModel: CardViewModel
    @State private var isEditable = false
    @State private var autoLockTimer: Timer?
    @State private var activeAlert: MyCardViewModel.ActiveAlert?
    @State private var activeShareSheet: MyCardViewModel.ActiveShareSheet?
    @State private var showingShareSheet = false
    @State var undoCardInfo = CardInfo()
    
    init(viewModel: MyCardViewModel, cardViewModel: CardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.cardViewModel = cardViewModel
    }
    
    var body: some View {
        ZStack {
            VStack() {
                CardDetailsView(viewModel: CardDetailsViewModel(appManager: viewModel.appManager), cardViewModel: cardViewModel, isEditable: $isEditable, isUnlocked: true) { isFavorited in
                    guard let id = cardViewModel.id else { return }
                    viewModel.appManager.actionManager.doAction(action: .setIsFavorited(id: id, isFavorited)) { result in
                        if result {
                            cardViewModel.isFavorited.toggle()
                        }
                    }
                }
                .frame(height: viewModel.appManager.constants.cardHeight)
                
                if isEditable {
                    ColorCarouselView(cardColor: $cardViewModel.cardColor, viewModel: ColorCarouselViewModel(appManager: viewModel.appManager))
                    AddButton(viewModel: viewModel, cardViewModel: cardViewModel, isEditable: $isEditable, showAlert: { errorMessage in self.activeAlert = .error(errorMessage) })
                }
                
                Spacer()
                
                HStack(spacing: 30) {
                    
                    Button(action: {
                        self.showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(RoundedButtonStyle())
                    
                    Button(action: {
                        if isEditable {
                            undo()
                        } else {
                            saveCurrentCard()
                        }
                        isEditable.toggle()
                    }) {
                        
                        Image(systemName: isEditable ? "arrow.uturn.backward.circle.fill" : "pencil.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                    }
                    .buttonStyle(RoundedButtonStyle())
                    
                    Button(action: {
                        self.resetAutoLockTimer()
                        self.activeAlert = .deleteConfirmation
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(RoundedButtonStyle())
                }
                .padding(.horizontal, 20)
            }
        }
        .onTapGesture {
            startAutoLockTimer()
        }
        .onAppear {
            startAutoLockTimer()
        }
        .onDisappear {
            resetAutoLockTimer()
            viewModel.updateCardColor(cardColor: cardViewModel.cardColor)
        }
        .navigationBarTitle(viewModel.card.cardName, displayMode: .inline)
        .alert(item: $activeAlert) { activeAlert in
            switch activeAlert {
            case .deleteConfirmation:
                return Alert(
                    title: Text("Delete Card"),
                    message: Text("Are you sure you want to delete this card?"),
                    primaryButton: .default(Text("Cancel"), action: {
                        self.startAutoLockTimer()
                        self.activeAlert = nil
                    }),
                    secondaryButton: .destructive(Text("Delete"), action: {
                        withAnimation {
                            viewModel.delete { result in
                                if result {
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    self.startAutoLockTimer()
                                    print("Error deleting the card")
                                }
                            }
                        }
                        self.activeAlert = nil
                    })
                )
            case .error(let errorMessage):
                return Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .actionSheet(isPresented: $showingShareSheet) {
            ActionSheet(
                title: Text("Share Card"),
                message: Text("Choose how you would like to share the card"),
                buttons: [
                    .default(Text("Share Inside App")) {
                        activeShareSheet = .insideShare
                        resetAutoLockTimer()
                    },
                    .default(Text("Share Outside App")) {
                        activeShareSheet = .outsideShare
                        resetAutoLockTimer()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(item: $activeShareSheet, onDismiss: { startAutoLockTimer() }) { activeShareSheet in
            switch activeShareSheet {
            case .insideShare:
                VStack {
                    Text("Scan this QR Code when adding a new card")
                    QRCodeView(qrCodeImage: viewModel.appManager.utils.generateCardQRCode(from:cardViewModel.getCardInfo()))
                        .frame(height: viewModel.appManager.constants.qrCodeHeight)
                        .padding()
                }
                .padding()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            case .outsideShare:
                ShareUIActivityController(shareItems: [viewModel.appManager.utils.getFormattedShareCardInfo(card: cardViewModel.getCardInfo())])
                    .presentationDetents([.medium, .large])
                
            }
        }
        .padding(.bottom, 20)
    }
}


// MARK: - Undo funcionality

extension MyCardView {
    
    // Copy by value instead of reference
    func saveCurrentCard() {
        let currentCard = viewModel.card
        undoCardInfo = CardInfo(cardName: currentCard.cardName, cardNumber: currentCard.cardNumber, expiryDate: currentCard.expiryDate, cvvCode: currentCard.cvvCode, cardColor: currentCard.cardColor, isFavorited: currentCard.isFavorited, pin: currentCard.pin)
    }
    
    func undo() {
        cardViewModel.cardName = undoCardInfo.cardName
        cardViewModel.cardNumber = undoCardInfo.cardNumber
        cardViewModel.cardColor = undoCardInfo.cardColor
        cardViewModel.cvvCode = undoCardInfo.cvvCode
        cardViewModel.expiryDate = undoCardInfo.expiryDate
        cardViewModel.isFavorited = undoCardInfo.isFavorited
        cardViewModel.pin = undoCardInfo.pin
    }
}

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.black.opacity(0.5) : Color.black.opacity(0.9))
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
    }
}

// Auto-lock Funcionality
extension MyCardView {
    private func startAutoLockTimer() {
        resetAutoLockTimer()
        self.autoLockTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func resetAutoLockTimer() {
        autoLockTimer?.invalidate()
    }
}


//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create a mock Card object for the preview
//        let mockCard = Card(context: PersistenceController.preview.container.viewContext)
//        mockCard.cardName = "Visa"
//        mockCard.cardNumber = "4234 5678 9012 3456"
//        mockCard.expiryDate = "12/25"
//        mockCard.cvvCode = "123"
//
//        let cardViewModel = CardViewModel(card: mockCard, appManager: AppManager(context: PersistenceController.preview.container.viewContext))
//        return CardView(viewModel: cardViewModel)
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .previewLayout(.sizeThatFits)
//            .padding()
//    }
//}

