//
//  Color+Extension.swift
//  SafeWallet
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI

extension Color {
    
    enum ColorName: String {
        case clear
        case black
        case white
        case gray
        case red
        case green
        case blue
        case orange
        case yellow
        case pink
        case purple
        case primary
        case secondary
        case systemBackground
        case inversedSystemBackground
    }
    
    init(_ colorName: ColorName) {
        switch colorName {
        case .clear:
            self = .clear
        case .black:
            self = .black
        case .white:
            self = .white
        case .gray:
            self = .gray
        case .red:
            self = .red
        case .green:
            self = .green
        case .blue:
            self = .blue
        case .orange:
            self = .orange
        case .yellow:
            self = .yellow
        case .pink:
            self = .pink
        case .purple:
            self = .purple
        case .primary:
            self = .primary
        case .secondary:
            self = .secondary
        case .systemBackground:
            self = Color(uiColor: .systemBackground)
        case .inversedSystemBackground:
            self = Color(uiColor:.inverseSystemBackground)
        }
    }
}
