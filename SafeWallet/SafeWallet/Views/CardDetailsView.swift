//
//  CardDetailsView.swift
//  SafeWallet
//
//  Created by Gonçalo on 24/12/2023.
//

import Foundation
import SwiftUI
import Combine

struct CardDetailsView: View {
    @Binding var cardName: String
    @Binding var cardNumber: String
    @Binding var expiryDate: String
    @Binding var cvvCode: String
    @Binding var cardColor: String
    @Binding var isUnlocked: Bool
    @StateObject var viewModel: CardDetailsViewModel
    
    var isEditable: Bool
    
    init(viewModel: CardDetailsViewModel, cardName: Binding<String>, cardNumber: Binding<String>, expiryDate: Binding<String>, cvvCode: Binding<String>, cardColor: Binding<String>, isEditable: Bool = true) {
        self._cardName = cardName
        self._cardNumber = cardNumber
        self._expiryDate = expiryDate
        self._cvvCode = cvvCode
        self._cardColor = cardColor
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isUnlocked = .constant(true)
        self.isEditable = isEditable
    }
    
    init(viewModel: CardDetailsViewModel, card: Card, isUnlocked: Binding<Bool>) {
        self._cardName = .constant(card.cardName)
        self._cardNumber = .constant(card.cardNumber)
        self._expiryDate = .constant(card.expiryDate)
        self._cvvCode = .constant(card.cvvCode)
        self._cardColor = .constant(card.cardColor)
        self._isUnlocked = isUnlocked
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.isEditable = false
    }
    
    init(viewModel: CardDetailsViewModel, card: Card, isUnlocked: Binding<Bool>, cardColor: Binding<String>) {
        self._cardName = .constant(card.cardName)
        self._cardNumber = .constant(card.cardNumber)
        self._expiryDate = .constant(card.expiryDate)
        self._cvvCode = .constant(card.cvvCode)
        self._cardColor = cardColor
        self._isUnlocked = isUnlocked
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.isEditable = false
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 15) {
                CardDetailsNameAndNumberView(cardName: $cardName, cardNumber: $cardNumber, isEditable: isEditable, isUnlocked: isUnlocked, viewModel: viewModel)
                
                HStack {
                    CardDetailsCVVView(cvvCode: $cvvCode, isEditable: isEditable, isUnlocked: isUnlocked, viewModel: viewModel)
                    Spacer()
                    Spacer()
                    CardDetailsExpiryDateView(expiryDate: $expiryDate, isEditable: isEditable, viewModel: viewModel, isUnlocked: isUnlocked)
                }
            }
            .padding()
            .background(Color(Color.ColorName(rawValue: cardColor) ?? .clear).opacity(viewModel.getCardBackgroundOpacity()))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 1)
            )
            .shadow(radius: 3)
            
            if let cardIssuerImage = viewModel.getCardIssuerImage(cardNumber: cardNumber) {
                cardIssuerImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 15)
                    .padding(.top, 8)
            }
        }
    }
}

fileprivate struct CardDetailsNameAndNumberView: View {
    @Binding var cardName: String
    @Binding var cardNumber: String
    var isEditable: Bool
    var isUnlocked: Bool
    var viewModel: CardDetailsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if isEditable {
                TextField("Name", text: $cardName)
                    .onChange(of: cardName) { _, newValue in
                        self.cardName = String(cardName.prefix(20)).uppercased()
                    }
            } else {
                MenuTextView(content: cardName.uppercased(), view: Text(cardName.uppercased()))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.inversedSystemBackground))
                
            }
            if isEditable {
                TextField("Number", text: $cardNumber)
                    .font(cardNumber.isEmpty ? .body : .title3)
                    .fontWeight(cardNumber.isEmpty ? .none : .bold)
                    .keyboardType(.numberPad)
                    .frame(width: UIScreen.main.bounds.width * 0.58)
                    .onChange(of: cardNumber, initial: true) { _, newValue in
                        self.cardNumber = self.viewModel.formatCardNumber(newValue)
                    }
            } else {
                HStack(spacing: 0) {
                    if !isUnlocked {
                        Text(String(repeating: "•", count: max(0, cardNumber.count - 4)))
                            .redacted(reason: .placeholder)
                        Text(" " + cardNumber.suffix(4))
                    } else {
                        MenuTextView(content: cardNumber, view: Text(cardNumber))
                            .foregroundStyle(Color(.inversedSystemBackground))
                    }
                }
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .layoutPriority(1)
                .textSelection(.enabled)
            }
        }
    }
}

fileprivate struct CardDetailsCVVView: View {
    @Binding var cvvCode: String
    var isEditable: Bool
    var isUnlocked: Bool
    var viewModel: CardDetailsViewModel
    
    var body: some View {
        if isEditable {
            TextField("CVV", text: $cvvCode)
                .keyboardType(.numberPad)
                .frame(width: UIScreen.main.bounds.width * 0.55)
                .onChange(of: cvvCode, initial: true) { _, newValue in
                    self.cvvCode = String(newValue.prefix(3))
                }
            
        } else {
            if !cvvCode.isEmpty {
                VStack {
                    Text("CVV")
                        .font(.caption)
                        .fontWeight(.semibold)
                    MenuTextView(content: cvvCode, view: Text(cvvCode))
                        .font(.headline)
                        .fontWeight(.bold)
                        .redacted(reason: isUnlocked ? [] : .placeholder)
                        .foregroundStyle(Color(.inversedSystemBackground))
                }
                
            }
        }
    }
}


fileprivate struct CardDetailsExpiryDateView: View {
    @Binding var expiryDate: String
    var isEditable: Bool
    var viewModel: CardDetailsViewModel
    var isUnlocked: Bool
    
    var body: some View {
        VStack(alignment: .trailing) {
            if isEditable {
                ExpiryDateTextField(expiryDate: $expiryDate)
                    .font(.headline)
                    .multilineTextAlignment(.trailing)
            } else {
                Text("Expires on")
                    .font(.caption)
                    .fontWeight(.semibold)
                MenuTextView(content: expiryDate, view: Text(expiryDate))
                    .font(.headline)
                    .fontWeight(.bold)
                    .redacted(reason: isUnlocked ? [] : .placeholder)
                    .foregroundStyle(Color(.inversedSystemBackground))
            }
        }
    }
}

struct ExpiryDateTextField: View {
    @Binding var expiryDate: String
    let maxDigits: Int = 4
    
    var body: some View {
        TextField("MM/YY", text: $expiryDate)
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
        
        let viewModel = CardDetailsViewModel(appManager: AppManager(context: context))
        
        // Binding variables for the preview
        let bindingCardName = Binding.constant("Visa")
        let bindingCardNumber = Binding.constant("4234 5678 0000 1111")
        let bindingExpiryDate = Binding.constant("12/25")
        let bindingCvvCode = Binding.constant("123")
        let bindingCardColor = Binding.constant("systemBackground")
        
        // Return the preview of CardDetailsView
        CardDetailsView(viewModel: viewModel,
                        cardName: bindingCardName,
                        cardNumber: bindingCardNumber,
                        expiryDate: bindingExpiryDate,
                        cvvCode: bindingCvvCode,
                        cardColor: bindingCardColor,
                        isEditable: false)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
