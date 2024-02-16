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
    @StateObject var viewModel: CardListViewModel
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
                                CardRow(cardViewModel: viewModel.getCardViewModel(for: card), appManager: viewModel.appManager) {
                                    if let index = cards.firstIndex(where: { $0.id == card.id }) {
                                        print("Deleting card at index: \(index)")
                                        viewModel.deleteCards(at: IndexSet(integer: index), from: cards)
                                    } else {
                                        print("Failed to find index for card")
                                    }
                                }
                                .padding([.vertical], 10)
                                .listRowInsets(EdgeInsets())
                            }
                            .foregroundColor(.inverseSystemBackground)
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(for: Card.self, destination: { card in
                MyCardView(viewModel: MyCardViewModel(card: card, appManager: viewModel.appManager), cardViewModel: viewModel.getCardViewModel(for: card))
            })
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationBarTitle("SafeWallet", displayMode: .automatic)
            .navigationBarItems(trailing: Button(action: {
                viewModel.showingAddCardView = true
            }) {
                Image(.addCard)
            })
            .sheet(isPresented: $viewModel.showingAddCardView) {
                AddCardView(viewModel: AddCardViewModel(appManager: viewModel.appManager))
                    .presentationDetents([.medium, .large])
            }
            .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
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
            Text("You currently have no cards")
                .font(.title)
                .fontWeight(.semibold)
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
