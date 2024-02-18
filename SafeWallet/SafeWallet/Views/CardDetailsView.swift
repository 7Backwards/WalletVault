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
    @StateObject var viewModel: CardDetailsViewModel
    @ObservedObject var cardViewModel: CardViewModel
    @Binding var isEditable: Bool
    var isUnlocked: Bool
    let setIsFavorited: (Bool) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 15) {
                    CardDetailsNameAndNumberView(cardName: $cardViewModel.cardName, cardNumber: $cardViewModel.cardNumber, isEditable: $isEditable, isUnlocked: isUnlocked,viewModel: viewModel)
                    
                    HStack() {
                        CardDetailsCVVView(cvvCode: $cardViewModel.cvvCode, isEditable: $isEditable, isUnlocked: isUnlocked, viewModel: viewModel)
                        
                        CardDetailsPinView(pin: $cardViewModel.pin, isEditable: $isEditable, isUnlocked: isUnlocked, viewModel: viewModel)
                        CardDetailsExpiryDateView(expiryDate: $cardViewModel.expiryDate, isEditable: $isEditable, viewModel: viewModel, isUnlocked: isUnlocked)
                    }
                }
                .padding()
                .background(Color(cardViewModel.cardColor).opacity(viewModel.getCardBackgroundOpacity()))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .shadow(radius: 3)
                
                if let cardIssuerImage = viewModel.getCardIssuerImage(cardNumber: cardViewModel.cardNumber) {
                    cardIssuerImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 15)
                        .padding(.top, 8)
                }
                
                Group {
                    Circle()
                        .fill(Color.systemBackground)
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.yellow)
                        .padding(.top, 0)
                        .padding(.trailing, 0)
                        .transition(.scale)
                        .opacity(cardViewModel.isFavorited ? 1 : 0.3)
                }
                .offset(x: 10, y: -10)
                .frame(width: 28, height: 28)
                .onTapGesture {
                    if let id = cardViewModel.id {
                        setIsFavorited(!cardViewModel.isFavorited)
                    } else {
                        cardViewModel.isFavorited.toggle()
                    }
                }
            }
            .padding(.horizontal, viewModel.appManager.constants.cardHorizontalMarginSpacing)
            .frame(width: geometry.size.width, height: viewModel.appManager.constants.cardHeight)
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
                    .onChange(of: cardName) { _, newValue in
                        self.cardName = String(cardName.prefix(20)).uppercased()
                    }
            } else {
                MenuTextView(content: cardName.uppercased(), isEditable: $isEditable, view: Text(cardName.uppercased()))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.inverseSystemBackground)
                
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
                        MenuTextView(content: cardNumber, isEditable: $isEditable, view: Text(cardNumber))
                            .foregroundStyle(Color.inverseSystemBackground)
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
    @Binding var isEditable: Bool
    var isUnlocked: Bool
    var viewModel: CardDetailsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditable {
                TextField("CVV", text: $cvvCode)
                    .keyboardType(.numberPad)
                    .onChange(of: cvvCode, initial: true) { _, newValue in
                        self.cvvCode = String(newValue.prefix(3))
                    }
                
            } else if !cvvCode.isEmpty {
                Text("CVV")
                    .font(.caption)
                    .fontWeight(.semibold)
                MenuTextView(content: cvvCode, isEditable: $isEditable, view: Text(cvvCode))
                    .font(.headline)
                    .fontWeight(.bold)
                    .redacted(reason: isUnlocked ? [] : .placeholder)
                    .foregroundStyle(Color.inverseSystemBackground)
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
            if isEditable {
                TextField("Pin", text: $pin)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .onChange(of: pin, initial: true) { _, newValue in
                        self.pin = String(newValue.prefix(4))
                    }
                
            } else if !pin.isEmpty {
                
                Text("Pin")
                    .font(.caption)
                    .fontWeight(.semibold)
                MenuTextView(content: pin, isEditable: $isEditable, view: Text(pin))
                    .font(.headline)
                    .fontWeight(.bold)
                    .redacted(reason: isUnlocked ? [] : .placeholder)
                    .foregroundStyle(Color.inverseSystemBackground)
            }
        }
        .frame(maxWidth: 50, alignment: .center)
    }
}

fileprivate struct CardDetailsExpiryDateView: View {
    @Binding var expiryDate: String
    @Binding var isEditable: Bool
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
                MenuTextView(content: expiryDate, isEditable: $isEditable, view: Text(expiryDate))
                    .font(.headline)
                    .fontWeight(.bold)
                    .redacted(reason: isUnlocked ? [] : .placeholder)
                    .foregroundStyle(Color.inverseSystemBackground)
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


//struct CardDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//
//        let viewModel = CardDetailsViewModel(appManager: AppManager(context: context))
//
//        let mockCard = Card(context: PersistenceController.preview.container.viewContext)
//        mockCard.cardName = "Visa"
//        mockCard.cardNumber = "4234 5678 9012 3456"
//        mockCard.expiryDate = "12/25"
//        mockCard.cvvCode = "123"
//
//        CardDetailsView(viewModel: viewModel,
//                        cardViewModel: CardViewModel(card: mockCard),
//                        isUnlocked: .constant(true))
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
