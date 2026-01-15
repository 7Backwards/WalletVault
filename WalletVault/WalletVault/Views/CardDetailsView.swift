//
//  CardDetailsView.swift
//  WalletVault
//
//  Created by Gonçalo on 24/12/2023.
//

import Foundation
import SwiftUI
import Combine

struct CardDetailsView: View {
    @ObservedObject var viewModel: CardDetailsViewModel

    init(appManager: AppManager, cardObject: CardObservableObject, isEditing: Binding<Bool>, isUnlocked: Bool, setIsFavorited: @escaping (Bool) -> Void) {
        self.viewModel = CardDetailsViewModel(appManager: appManager, cardObject: cardObject, isEditing: isEditing, isUnlocked: isUnlocked, setIsFavorited: setIsFavorited)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 15) {
                CardDetailsNameAndNumberView(
                    cardName: $viewModel.cardObject.cardName,
                    cardNumber: $viewModel.cardObject.cardNumber,
                    isEditable: $viewModel.isEditable,
                    isUnlocked: viewModel.isUnlocked,
                    viewModel: viewModel
                )

                HStack(spacing: 15) {
                    CardDetailsCVVView(
                        cvvCode: $viewModel.cardObject.cvvCode,
                        isEditable: $viewModel.isEditable,
                        isUnlocked: viewModel.isUnlocked,
                        viewModel: viewModel
                    )

                    CardDetailsPinView(
                        pin: $viewModel.cardObject.pin,
                        isEditable: $viewModel.isEditable,
                        isUnlocked: viewModel.isUnlocked,
                        viewModel: viewModel
                    )

                    CardDetailsExpiryDateView(
                        expiryDate: $viewModel.cardObject.expiryDate,
                        isEditable: $viewModel.isEditable,
                        viewModel: viewModel,
                        isUnlocked: viewModel.isUnlocked
                    )
                }
            }
            .padding()
            .background(Color(hex: viewModel.cardObject.cardColor?.hexValue ?? "").opacity(viewModel.getCardBackgroundOpacity()))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)

            if let cardIssuerImage = viewModel.getCardIssuerImage(cardNumber: viewModel.cardObject.cardNumber) {
                cardIssuerImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 15)
                    .padding(.top, 8)
            }
        }
        .overlay(
            starIcon,
            alignment: .topTrailing
        )
        .padding(.trailing, 16)
        .padding(.leading, 16)
        .padding(.top, 10)
    }   

    private var starIcon: some View {
        Group {
            Circle()
                .fill(Color.systemBackground)
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.yellow)
                .transition(.scale)
                .opacity(viewModel.cardObject.isFavorited ? 1 : 0.3)
        }
        .frame(width: 30, height: 30)
        .offset(x: 10, y: -10)
        .accessibilityIdentifier("favoriteButton")
        .onTapGesture {
            if viewModel.cardObject.id != nil {
                viewModel.setIsFavorited(!viewModel.cardObject.isFavorited)
            } else {
                viewModel.cardObject.isFavorited.toggle()
            }
        }
    }
}

fileprivate struct CardDetailsNameAndNumberView: View {
    @Binding var cardName: String
    @Binding var cardNumber: String
    @Binding var isEditable: Bool
    var isUnlocked: Bool
    var viewModel: CardDetailsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if isEditable {
                TextField("Name", text: $cardName)
                    .accessibilityIdentifier("cardNameField")
                    .onChange(of: cardName) { _, newValue in
                        self.cardName = String(cardName.prefix(20)).uppercased()
                    }
                    .fontWeight(.bold)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .font(.headline)
                    .foregroundStyle(Color.secondary)
            } else {
                MenuTextView(content: cardName.uppercased(), isEditable: $isEditable, isUnlocked: isUnlocked, view: Text(cardName.uppercased()))
                    .font(.headline)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.inverseSystemBackground)
                    .padding(.top, 1)
                
            }
            if isEditable {
                TextField("Number", text: $cardNumber)
                    .accessibilityIdentifier("cardNumberField")
                    .font(.title3)
                    .keyboardType(.numberPad)
                    .fontWeight(.bold)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .foregroundStyle(Color.secondary)
                    .onChange(of: cardNumber, initial: true) { _, newValue in
                        self.cardNumber = self.viewModel.formatCardNumber(newValue)
                    }
            } else {
                HStack(spacing: 0) {
                    if !isUnlocked {
                        Text(String(repeating: "•", count: max(0, cardNumber.count - 4)))
                            .redacted(reason: .placeholder)
                            .dynamicTypeSize(.xSmall ... .xxxLarge)
                        Text(" " + cardNumber.suffix(4))
                            .dynamicTypeSize(.xSmall ... .xxxLarge)
                    } else {
                        MenuTextView(content: cardNumber, isEditable: $isEditable, isUnlocked: isUnlocked, view: Text(cardNumber))
                            .dynamicTypeSize(.xSmall ... .xxxLarge)
                            .foregroundStyle(Color.inverseSystemBackground)
                    }
                }
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .layoutPriority(1)
                .textSelection(.enabled)
                .padding(.top, 1.75)
            }
        }
    }
}

fileprivate struct CardDetailsCVVView: View {
    @Binding var cvvCode: String
    @Binding var isEditable: Bool
    var isUnlocked: Bool
    var viewModel: CardDetailsViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(isEditable || cvvCode.count == 3 ? "CVV" : "")
                .font(.caption)
                .dynamicTypeSize(.xSmall ... .xxxLarge)
                .fontWeight(.semibold)
                .padding(.top, isEditable ? 0 : 0.5)
            if isEditable {
                TextField("CVV", text: $cvvCode)
                    .accessibilityIdentifier("cvvField")
                    .font(.headline)
                    .fontWeight(.bold)
                    .keyboardType(.numberPad)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .foregroundStyle(Color.secondary)
                    .onChange(of: cvvCode, initial: true) { _, newValue in
                        self.cvvCode = String(newValue.prefix(3))
                    }
                
            } else if !cvvCode.isEmpty {
                MenuTextView(content: cvvCode, isEditable: $isEditable, isUnlocked: isUnlocked, view: Text(cvvCode))
                    .font(.headline)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .fontWeight(.bold)
                    .redacted(reason: isUnlocked ? [] : .placeholder)
                    .foregroundStyle(Color.inverseSystemBackground)
                    .padding(.top, 0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

fileprivate struct CardDetailsPinView: View {
    @Binding var pin: String
    @Binding var isEditable: Bool
    var isUnlocked: Bool
    var viewModel: CardDetailsViewModel

    var body: some View {
        VStack(alignment: .center) {
            Text(isEditable || pin.count == 4 ? "Pin" : "")
                .font(.caption)
                .dynamicTypeSize(.xSmall ... .xxxLarge)
                .fontWeight(.semibold)
                .padding(.top, isEditable ? 0 : 0.5)
            if isEditable {
                TextField("Pin", text: $pin)
                    .accessibilityIdentifier("pinField")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .foregroundStyle(Color.secondary)
                    .onChange(of: pin, initial: true) { _, newValue in
                        self.pin = String(newValue.prefix(4))
                    }
                
            } else if !pin.isEmpty {
                MenuTextView(content: pin, isEditable: $isEditable, isUnlocked: isUnlocked, view: Text(pin))
                    .font(.headline)
                    .fontWeight(.bold)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .redacted(reason: isUnlocked ? [] : .placeholder)
                    .foregroundStyle(Color.inverseSystemBackground)
                    .padding(.top, 0.8)
            }
        }
    }
}

fileprivate struct CardDetailsExpiryDateView: View {
    @Binding var expiryDate: String
    @Binding var isEditable: Bool
    var viewModel: CardDetailsViewModel
    var isUnlocked: Bool

    var body: some View {
        VStack(alignment: .trailing) {
            Text(isEditable || expiryDate.count == 5 ? "Expires on" : "")
                .font(.caption)
                .lineLimit(1)
                .dynamicTypeSize(.xSmall ... .xxxLarge)
                .fontWeight(.semibold)
                .padding(.top, isEditable ? 0 : 0.5)
            if isEditable {
                ExpiryDateTextField(expiryDate: $expiryDate)
                    .font(.headline)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.trailing)
            } else {
                MenuTextView(content: expiryDate, isEditable: $isEditable, isUnlocked: isUnlocked, view: Text(expiryDate))
                    .font(.headline)
                    .dynamicTypeSize(.xSmall ... .xxxLarge)
                    .fontWeight(.bold)
                    .redacted(reason: isUnlocked ? [] : .placeholder)
                    .foregroundStyle(Color.inverseSystemBackground)
                    .padding(.top, 0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ExpiryDateTextField: View {
    @Binding var expiryDate: String
    let maxDigits: Int = 4
    
    var body: some View {
        TextField("MM/YY", text: $expiryDate)
            .accessibilityIdentifier("expiryDateField")
            .keyboardType(.numberPad)
            .onChange(of: expiryDate, initial: true) { _, newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                
                if filtered.count > 2 {
                    let prefix = String(filtered.prefix(2))
                    let suffix = String(filtered.suffix(from: filtered.index(filtered.startIndex, offsetBy: 2)))
                    expiryDate = "\(prefix)/\(suffix)"
                } else {
                    expiryDate = filtered
                }
                
                if expiryDate.count > 5 { // "MM/YY" is 5 characters including the slash
                    expiryDate = String(expiryDate.prefix(5))
                }
            }
    }
}


struct CardDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        let mockCard = Card(context: context)
        mockCard.cardName = "Visa"
        mockCard.cardNumber = "1234 5678 9012 3456"
        mockCard.expiryDate = "12/25"
        mockCard.cvvCode = "123"

        let mockCardObservableObject = CardObservableObject(card: mockCard)

        // Make sure you're using a binding to a boolean for isEditing
        // If this is a view that doesn't change the editing state, you can use .constant(false)
        let isEditing = Binding.constant(true)

        // Create a closure that matches the expected type for setIsFavorited
        let setIsFavorited: (Bool) -> Void = { isFavorited in
            // Perform the action to set the card as a favorite
        }

        // Replace `isUnlocked` with a static value if it doesn't change in the preview
        let isUnlocked = true

        return CardDetailsView(
            appManager: AppManager(context: context),
            cardObject: mockCardObservableObject,
            isEditing: isEditing,
            isUnlocked: isUnlocked,
            setIsFavorited: setIsFavorited
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
