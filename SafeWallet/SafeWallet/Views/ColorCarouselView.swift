//
//  ColorCarouselView.swift
//  SafeWallet
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI

struct ColorCarouselView: View {
    @Binding var cardColor: String
    @StateObject var viewModel: ColorCarouselViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.appManager.constants.colors, id: \.self) { colorName in
                        let color = Color(colorName).opacity(viewModel.getCardBackgroundOpacity())
                        Circle()
                            .fill(color)
                            .frame(width: viewModel.appManager.constants.colorCircleSize, height: viewModel.appManager.constants.colorCircleSize)
                            .overlay(
                                Circle()
                                    .stroke(Color.clear)
                            )
                            .scaleEffect(cardColor == colorName.rawValue ? 1.2 : 1.0)
                            .shadow(color: Color(uiColor: .inverseSystemBackground), radius: 0)
                            .onTapGesture {
                                withAnimation {
                                    self.cardColor = colorName.rawValue
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
