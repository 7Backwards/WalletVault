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
    @ObservedObject var viewModel: CardRowViewModel
    
    init(cardObject: CardObservableObject, appManager: AppManager, activeAlert: Binding<CardListViewModel.ActiveAlert?>) {
        self.viewModel = CardRowViewModel(appManager: appManager, cardObject: cardObject, activeAlert: activeAlert)
    }
    
    var body: some View {
        ZStack {
            CardDetailsView(appManager: viewModel.appManager, cardObject: viewModel.cardObject, isEditing: $viewModel.isEditable, isUnlocked: false) { isFavorited in
                guard let id = viewModel.cardObject.id else { return }
                viewModel.appManager.actionManager.doAction(action: .setIsFavorited(id: id, isFavorited)) { result in
                    if result {
                        viewModel.cardObject.isFavorited.toggle()
                    }
                }
            }
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
                                    guard let id = viewModel.cardObject.id else {
                                        return
                                    }
                                    viewModel.activeAlert = .removeCard(id)
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
