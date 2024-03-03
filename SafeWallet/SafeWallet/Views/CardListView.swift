//
//  ContentView.swift
//  SafeWallet
//
//  Created by Gonçalo on 21/12/2023.
//

import SwiftUI
import CoreData

struct CardListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: CardListViewModel
    @State private var path = NavigationPath()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.isFavorited, ascending: false)],
        animation: .default)
    var cards: FetchedResults<Card>
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack {
                    SearchBar(text: $viewModel.searchText)
                        .background(Color(UIColor.systemBackground))
                        .padding()
                    if cards.isEmpty {
                        NoContentView()
                    } else {
                        ForEach(cards.filter {
                            viewModel.searchText.isEmpty ||
                            $0.cardNumber.contains(viewModel.searchText) || $0.cardName.contains(viewModel.searchText)
                        }, id: \.self) { card in
                            Button {
                                viewModel.authenticate { result in
                                    if result {
                                        path.append(card)
                                    }
                                }
                            } label: {
                                CardRow(cardObject: viewModel.getCardObservableObject(for: card), appManager: viewModel.appManager, activeAlert: $viewModel.activeAlert)
                                    .padding(.bottom, 10)
                                    .frame(height: viewModel.appManager.constants.cardHeight)
                                    .listRowInsets(EdgeInsets())
                            }
                            .foregroundColor(.inverseSystemBackground)
                        }
                    }
                }
            }
            .navigationDestination(for: Card.self) { card in
                MyCardView(appManager: viewModel.appManager, cardObject: viewModel.getCardObservableObject(for: card))
            }
            .onAppear {
                viewModel.appManager.utils.requestNotificationPermission()
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationBarTitle("SafeWallet", displayMode: .automatic)
            .navigationBarItems(trailing: TrailingNavigationItems(viewModel: viewModel))
            .alert(item: $viewModel.activeAlert) { activeAlert in
                switch activeAlert {
                case .cardAdded:
                    return Alert(
                        title: Text("Success"),
                        message: Text("Card imported successfully."),
                        dismissButton: .default(Text("OK"))
                    )
                case .removeCard(let id):
                    return  Alert(
                        title: Text("Delete Card"),
                        message: Text("Are you sure you want to delete this card?"),
                        primaryButton: .default(Text("Cancel"), action: { viewModel.activeAlert = nil }),
                        secondaryButton: .destructive(Text("Delete"), action: {
                            withAnimation {
                                viewModel.deleteCard(id: id, from: cards)
                            }
                            viewModel.activeAlert = nil
                        })
                    )
                case .error:
                    return Alert(
                        title: Text("Error"),
                        message: Text("An error has occurred, please try again."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .sheet(item: $viewModel.activeShareSheet) { activeSheet in
                switch activeSheet {
                case .addCard:
                    AddCardView(appManager: viewModel.appManager)
                        .presentationDetents([.height(300)])
                        .presentationDragIndicator(.visible)
                case .scanQRCode:
                    QRCodeScannerView(viewModel: viewModel)
                        .presentationDetents([.height(300)])
                        .presentationDragIndicator(.visible)
                }
            }
            .background(Color.systemBackground.edgesIgnoringSafeArea(.all))
        }
        .onReceive(viewModel.appManager.notificationHandler.$selectedCardID) { selectedCardID in
            if let selectedId = selectedCardID, let selectedCard = cards.first(where: { $0.objectID == selectedId}) {
                path.append(selectedCard)
            }
        }
    }
}

struct TrailingNavigationItems: View {
    @StateObject var viewModel: CardListViewModel
    var body: some View {
        HStack {
            Button(action: {
                viewModel.activeShareSheet = .scanQRCode
            }) {
                Image(systemName: "qrcode.viewfinder")
                    .foregroundStyle(.inverseSystemBackground)
            }
            
            Button(action: {
                viewModel.activeShareSheet = .addCard
            }) {
                Image(systemName: "plus")
                    .foregroundStyle(.inverseSystemBackground)
            }
        }
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
            Text("Tap + to add your first card!")
                .font(.largeTitle)
                .fontWeight(.thin)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
}


struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
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
            print("Error fetching or saving mock cards: \(error)")
        }
        
        return CardListView(viewModel: CardListViewModel(appManager: AppManager(context: context)))
            .environment(\.managedObjectContext, context)
    }
}
