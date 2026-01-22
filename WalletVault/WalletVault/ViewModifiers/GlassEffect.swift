//
//  GlassEffect.swift
//  WalletVault
//
//  Created by Claude on 09/01/2026.
//

import SwiftUI

struct GlassEffect: ViewModifier {
    var opacity: Double = 0.1
    var blurRadius: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .background(
                Material.thin
                    .opacity(opacity)
            )
            .blur(radius: blurRadius / 10, opaque: false)
            .cornerRadius(12)
    }
}

struct FrostGlass: ViewModifier {
    var opacity: Double = 0.05
    var blurRadius: CGFloat = 5

    func body(content: Content) -> some View {
        content
            .background(
                Material.ultraThin
                    .opacity(opacity)
            )
            .blur(radius: blurRadius / 10, opaque: false)
            .cornerRadius(10)
    }
}

extension View {
    func glassEffect(opacity: Double = 0.1, blurRadius: CGFloat = 10) -> some View {
        modifier(GlassEffect(opacity: opacity, blurRadius: blurRadius))
    }

    func frostGlass(opacity: Double = 0.05, blurRadius: CGFloat = 5) -> some View {
        modifier(FrostGlass(opacity: opacity, blurRadius: blurRadius))
    }
}
