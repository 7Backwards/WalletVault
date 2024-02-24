//
//  AppConstants.swift
//  SafeWallet
//
//  Created by Gonçalo on 21/01/2024.
//

import SwiftUI

enum AddCardErrorType: Error {
    case invalidDate
    case savingError
    case shortCardNumber
}

class AppConstants: ObservableObject {
    @Published var cardBackgroundOpacity = 0.35
    @Published var colors: [Color] = [.red, .orange, .systemBackground, .blue, .green]
    @Published var colorCircleSize: CGFloat = 40
    @Published var cardHeight: CGFloat = 170
    @Published var cardHorizontalMarginSpacing: CGFloat = 20
    @Published var cardVerticalMarginSpacing: CGFloat = 20
    @Published var qrCodeHeight: CGFloat = 200
}
