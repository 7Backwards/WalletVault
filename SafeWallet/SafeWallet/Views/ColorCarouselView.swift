//
//  ColorCarouselView.swift
//  SafeWallet
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI

struct ColorCarouselView: View {
    @ObservedObject var viewModel: ColorCarouselViewModel
    
    init(cardColor: Binding<String>, appManager: AppManager) {
        self.viewModel = ColorCarouselViewModel(appManager: appManager, cardColor: cardColor)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.appManager.constants.colors, id: \.self) { color in
                        let colorWithOpacity = color.opacity(viewModel.getCardBackgroundOpacity())
                        Circle()
                            .fill(colorWithOpacity)
                            .frame(width: viewModel.appManager.constants.colorCircleSize, height: viewModel.appManager.constants.colorCircleSize)
                            .overlay(
                                Circle()
                                    .stroke(Color.clear)
                            )
                            .scaleEffect(viewModel.cardColor == color.name ? 1.2 : 1.0)
                            .shadow(color: Color.inverseSystemBackground, radius: 0)
                            .onTapGesture {
                                withAnimation {
                                    self.viewModel.cardColor = color.name
                                }
                            }
                    }
                }
                .frame(width: geometry.size.width)
                .frame(height: viewModel.appManager.constants.colorCircleSize * 1.4)
            }
        }
        .frame(height: viewModel.appManager.constants.colorCircleSize * 1.4)
    }
}
