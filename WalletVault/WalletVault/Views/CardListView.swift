//
//  ContentView.swift
//  WalletVault
//
//  Created by Gonçalo on 21/12/2023.
//

import SwiftUI
import CoreData

struct CardListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.sizeCategory) var sizeCategory
    @ObservedObject var viewModel: CardListViewModel
    @State private var path = NavigationPath()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.isFavorited, ascending: false)],
        animation: .default)
    var cards: FetchedResults<Card>

    /// Filtered cards based on search text
    private var filteredCards: [Card] {
        cards.filter {
            viewModel.searchText.isEmpty ||
            $0.cardNumber.contains(viewModel.searchText) ||
            $0.cardName.capitalized.contains(viewModel.searchText.capitalized)
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            cardListContent
            .onTapGesture {
                // Dismiss keyboard when tapping outside search bar
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationDestination(for: Card.self) { card in
                MyCardView(appManager: viewModel.appManager, cardObject: viewModel.getCardObservableObject(for: card))
            }
            .onAppear {
                viewModel.appManager.utils.requestNotificationPermission()
            }
            .navigationBarTitle("WalletVault", displayMode: .automatic)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !ProcessInfo.processInfo.isiOSAppOnMac {
                        Button {
                            viewModel.requestCameraPermission {
                                if $0 {
                                    viewModel.activeShareSheet = .scanQRCode
                                }
                            }
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .toolbarBackgroundVisibility(.hidden, for: .bottomBar)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    // Search bar on the left
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search cards", text: $viewModel.searchText)
                    }
                    .padding(10)
                    .glassEffect()

                    // Add button on the right
                    Button {
                        viewModel.activeShareSheet = .addCard
                    } label: {
                        Image(systemName: "plus")
                            .tint(.primary)
                            .padding(10)
                    }
                    .glassEffect()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .alert(item: $viewModel.activeAlert) { activeAlert in
            switch activeAlert {
            case .cardAdded:
                return viewModel.appManager.utils.requestCardAddedAlert()
            case .removeCard(let id):
                return viewModel.appManager.utils.requestRemoveCardAlert {
                    viewModel.activeAlert = nil
                } deleteAction: {
                    withAnimation {
                        viewModel.deleteCard(id: id, from: cards)
                    }
                    viewModel.activeAlert = nil
                }
            case .error:
                return viewModel.appManager.utils.requestDefaultErrorAlert()
            case .requestCameraPermission:
                return viewModel.appManager.utils.requestCameraPermissionAlert()
            }
        }
        .sheet(item: $viewModel.activeShareSheet) { activeSheet in
            switch activeSheet {
            case .addCard:
                AddCardView(appManager: viewModel.appManager)
                    .presentationDetents([.height(380)])
                    .presentationDragIndicator(.visible)
            case .scanQRCode:
                QRCodeScannerView(viewModel: viewModel)
                    .presentationDetents([.height(560)])
                    .presentationDragIndicator(.visible)
            }
        }
        .onReceive(viewModel.appManager.notificationHandler.$selectedCardID) { selectedCardID in
            if let selectedId = selectedCardID, let selectedCard = cards.first(where: { $0.objectID == selectedId}) {
                Logger.log("Showing card details by force selection of card \(selectedCard)")
                path.append(selectedCard)
            }
        }
    }

    /// Shared card list content view
    @ViewBuilder
    private var cardListContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                if cards.isEmpty {
                    NoContentView()
                } else if filteredCards.isEmpty {
                    NoSearchResultsView()
                } else {
                    ForEach(filteredCards, id: \.self) { card in
                        Button {
                            viewModel.authenticate { result in
                                if result {
                                    Logger.log("User did tap on card \(card)")
                                    path.append(card)
                                }
                            }
                        } label: {
                            CardRow(cardObject: viewModel.getCardObservableObject(for: card), appManager: viewModel.appManager, activeAlert: $viewModel.activeAlert)
                        }
                        .foregroundColor(.inverseSystemBackground)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }
}

struct NoSearchResultsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.secondary)
            Text("No cards found")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
            Spacer()
        }
        .padding()
    }
}

struct NoContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "creditcard.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 60)
                .foregroundColor(.secondary)
            Text("No cards yet")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text("Tap the + button to add your first card")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary.opacity(0.8))
            Spacer()
        }
        .padding()
    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let cardNumbers = [
                    "4234 5678 0000 1111", "1234 5678 1111 2222", "1234 5678 2222 3333",
                    "1234 5678 3333 4444", "1234 5678 4444 5555", "1234 5678 5555 6666",
                    "1234 5678 6666 7777", "1234 5678 7777 8888", "1234 5678 8888 9999", "1234 5678 9999 0000"
                ]
                let expiryDates = [
                    "12/25", "11/24", "10/23", "09/22", "08/21",
                    "07/20", "06/19", "05/18", "04/17", "03/16"
                ]
                let cvvCodes = [
                    "123", "234", "345", "456", "567",
                    "678", "789", "890", "901", "012"
                ]
                let cardNames = [
                    "Visa", "MasterCard", "Amex", "Discover", "UnionPay",
                    "JCB", "Maestro", "Visa Electron", "Mir", "Troy"
                ]
                
                for i in 0..<cardNumbers.count {
                    let newCard = Card(context: context)
                    newCard.cardNumber = cardNumbers[i]
                    newCard.expiryDate = expiryDates[i]
                    newCard.cvvCode = cvvCodes[i]
                    newCard.cardName = cardNames[i]
                }
                try context.save()
            }
        } catch {
            Logger.log("Error fetching or saving mock cards: \(error)", level: .error)
        }
        
        return CardListView(viewModel: CardListViewModel(appManager: AppManager(context: context)))
            .environment(\.managedObjectContext, context)
    }
}
