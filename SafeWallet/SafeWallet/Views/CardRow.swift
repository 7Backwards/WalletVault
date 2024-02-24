//
//  CardRow.swift
//  SafeWallet
//
//  Created by Gonçalo on 13/02/2024.
//

import Foundation
import SwiftUI

struct CardRow: View {
    
    @GestureState private var gestureDragOffset = CGSize.zero
    @State private var dragOffset = CGSize.zero
    @State var isEditable = false
    @ObservedObject var appManager: AppManager
    @ObservedObject var cardViewModel: CardViewModel
    @Binding var activeAlert: CardListViewModel.ActiveAlert?
    
    init(cardViewModel: CardViewModel, appManager: AppManager, activeAlert: Binding<CardListViewModel.ActiveAlert?>) {
        self.cardViewModel = cardViewModel
        self.appManager = appManager
        self._activeAlert = activeAlert
    }
    
    var body: some View {
        ZStack {
            CardDetailsView(viewModel: CardDetailsViewModel(appManager: appManager), cardViewModel: cardViewModel, isEditable: $isEditable, isUnlocked: false) { isFavorited in
                guard let id = cardViewModel.id else { return }
                appManager.actionManager.doAction(action: .setIsFavorited(id: id, isFavorited)) { result in
                    if result {
                        cardViewModel.isFavorited.toggle()
                    }
                }
            }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
                .cornerRadius(10)
                .shadow(radius: 5)
                .offset(x: dragOffset.width + gestureDragOffset.width)
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .updating($gestureDragOffset, body: { (value, state, _) in
                            let translationX = value.translation.width
                            if translationX < 0, translationX > -70 {
                                state = CGSize(width: translationX, height: 0)
                            }
                        })
                        .onEnded { value in
                            if value.translation.width < 0 {
                                if value.translation.width <= -50 {
                                    withAnimation {
                                        dragOffset = .zero
                                        guard let id = cardViewModel.id else {
                                            // TODO: Add log
                                            return
                                        }
                                        activeAlert = .removeCard(id)
                                    }
                                }
                            }
                        }
                )
            
            if gestureDragOffset.width < -10 {
                HStack {
                    Spacer()
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding()
                        .frame(width: abs(gestureDragOffset.width))
                }
            }
        }
    }
}
