//
//  ColorCarouselView.swift
//  SafeWallet
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI

struct ColorCarouselView: View {
    @ObservedObject var viewModel: ColorCarouselViewModel
    @Binding var isColorPickerPresented: Bool
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ColorEntity.isDefault, ascending: false)],
        animation: .default)
    var colorsEntity: FetchedResults<ColorEntity>

    init(cardColor: Binding<ColorEntity?>, isColorPickerPresented: Binding<Bool>, appManager: AppManager) {
        self.viewModel = ColorCarouselViewModel(appManager: appManager, cardColor: cardColor)
        self._isColorPickerPresented = isColorPickerPresented
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(colorsEntity, id: \.self) { colorEntity in
                    let color = Color(hex: colorEntity.hexValue ?? "")
                    let colorWithOpacity = color.opacity(viewModel.getCardBackgroundOpacity())
                    Circle()
                        .fill(colorWithOpacity)
                        .frame(width: viewModel.appManager.constants.colorCircleSize, height: viewModel.appManager.constants.colorCircleSize * 1.3)
                        .overlay(
                            Circle()
                                .stroke(viewModel.cardColor == colorEntity ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .scaleEffect(viewModel.cardColor == colorEntity ? 1.2 : 1.0)
                        .overlay(
                            Group {
                                if viewModel.cardColor == colorEntity, !colorEntity.isDefault {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        )
                        .onTapGesture {
                            if viewModel.cardColor == colorEntity, !colorEntity.isDefault {
                                viewModel.removeSelectedColor()
                            } else {
                                withAnimation(.easeInOut) {
                                    viewModel.cardColor = colorEntity
                                }
                            }
                        }
                }
                
                ZStack {
                    Circle()
                        .fill(.clear)
                        .frame(width: viewModel.appManager.constants.colorCircleSize, height: viewModel.appManager.constants.colorCircleSize * 1.3)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                                .font(.system(size: 24, weight: .bold))
                        )
                        .onTapGesture {
                            isColorPickerPresented = true
                        }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

struct ColorCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let cardColor = ColorEntity(context: context)
        cardColor.hexValue = "#FF0000"
        // Create a sample AppManager with the preview context
        let appManager = AppManager(context: context)
        
        return ColorCarouselView(
            cardColor: .constant(cardColor),
            isColorPickerPresented: .constant(false),
            appManager: appManager
        )
        .environment(\.managedObjectContext, context)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
