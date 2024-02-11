//
//  AppConstants.swift
//  SafeWallet
//
//  Created by Gonçalo on 21/01/2024.
//

import SwiftUI

class AppConstants: ObservableObject {
    @Published var cardBackgroundOpacity = 0.35
    @Published var colors: [Color.ColorName] = [.red, .orange, .systemBackground, .blue, .green]
    @Published var colorCircleSize: CGFloat = 40
}
