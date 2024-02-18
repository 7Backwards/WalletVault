//
//  CardRow.swift
//  SafeWallet
//
//  Created by Gonçalo on 13/02/2024.
//

import Foundation
import SwiftUI

struct CardRow: View {
    var onDelete: () -> Void
    
    @GestureState private var gestureDragOffset = CGSize.zero
    @State private var dragOffset = CGSize.zero
    @State private var shouldShowDeleteConfirmation = false
    @State var isEditable = false
    @ObservedObject var appManager: AppManager
    @ObservedObject var cardViewModel: CardViewModel
    
    init(cardViewModel: CardViewModel, appManager: AppManager, onDelete: @escaping () -> Void) {
        self.cardViewModel = cardViewModel
        self.appManager = appManager
        self.onDelete = onDelete
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
                                        shouldShowDeleteConfirmation = true
                                    }
                                }
                            }
                        }
                )
            
                .alert(isPresented: $shouldShowDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Card"),
                        message: Text("Are you sure you want to delete this card?"),
                        primaryButton: .default(Text("Cancel"), action: { shouldShowDeleteConfirmation = false }),
                        secondaryButton: .destructive(Text("Delete"), action: {
                            withAnimation {
                                onDelete()
                            }
                            shouldShowDeleteConfirmation = false
                        })
                    )
                }
            
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
