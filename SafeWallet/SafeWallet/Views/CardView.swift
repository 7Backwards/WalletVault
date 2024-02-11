//
//  CardView.swift
//  SafeWallet
//
//  Created by Gonçalo on 08/01/2024.
//

import SwiftUI

struct CardView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: CardViewModel
    @State private var autoLockTimer: Timer?
    @State var cardColor: String
    @State var cardName: String
    @State var cardNumber: String
    @State var expiryDate: String
    @State var cvvCode: String
    @State private var isEditable = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    init(viewModel: CardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _cardColor = State(wrappedValue: viewModel.card.cardColor)
        _cardName = State(wrappedValue: viewModel.card.cardName)
        _cardNumber = State(wrappedValue: viewModel.card.cardNumber)
        _cvvCode = State(wrappedValue: viewModel.card.cvvCode)
        _expiryDate = State(wrappedValue: viewModel.card.expiryDate)
    }

    var body: some View {
        ZStack {
            VStack {
                CardDetailsView(viewModel: CardDetailsViewModel(appManager: viewModel.appManager), cardName: $cardName, cardNumber: $cardNumber, expiryDate: $expiryDate, cvvCode: $cvvCode, cardColor: $cardColor, isEditable: $isEditable, isUnlocked: .constant(true))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .onTapGesture {
                        // User tapped the card details, so reset the auto-lock timer
                        self.startAutoLockTimer()
                    }
                
                ColorCarouselView(cardColor: $cardColor, viewModel: ColorCarouselViewModel(appManager: viewModel.appManager))
                
                if isEditable {
                    AddButton(viewModel: viewModel, id: viewModel.card.objectID, cardName: $cardName, cardNumber: $cardNumber, expiryDate: $expiryDate, cvvCode: $cvvCode, cardColor: $cardColor, alertMessage: $alertMessage, showAlert: $showAlert, isEditable: $isEditable, presentationMode: nil)
                }
                
                Spacer()
                
                HStack(spacing: 30) {
                    
                    Button(action: {
                        // Perform share action
                    }) {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(RoundedButtonStyle())
                    
                    Button(action: {
                        isEditable.toggle()
                    }) {
                        if !isEditable {
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        }
                    }
                    .buttonStyle(RoundedButtonStyle())
                    
                    Button(action: {
                        self.resetAutoLockTimer()
                        viewModel.shouldShowDeleteConfirmation = true
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
        .onAppear {
            startAutoLockTimer()
        }
        .onDisappear {
            resetAutoLockTimer()
            viewModel.updateCardColor(cardColor: cardColor)
        }
        .navigationBarTitle(viewModel.card.cardName, displayMode: .inline)
        .alert(isPresented: $viewModel.shouldShowDeleteConfirmation) {
            Alert(
                title: Text("Delete Card"),
                message: Text("Are you sure you want to delete this card?"),
                primaryButton: .default(Text("Cancel"), action: {
                    self.startAutoLockTimer()
                    viewModel.shouldShowDeleteConfirmation = false }),
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
                    viewModel.shouldShowDeleteConfirmation = false
                })
            )
        }
        .padding(.bottom, 20)
    }
}

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.primary.opacity(0.5) : Color.primary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock Card object for the preview
        let mockCard = Card(context: PersistenceController.preview.container.viewContext)
        mockCard.cardName = "Visa"
        mockCard.cardNumber = "4234 5678 9012 3456"
        mockCard.expiryDate = "12/25"
        mockCard.cvvCode = "123"
        
        let cardViewModel = CardViewModel(card: mockCard, appManager: AppManager(context: PersistenceController.preview.container.viewContext))
        return CardView(viewModel: cardViewModel)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

// Auto-lock Funcionality
extension CardView {
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
