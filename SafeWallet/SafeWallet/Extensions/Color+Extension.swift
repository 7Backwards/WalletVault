//
//  Color+Extension.swift
//  SafeWallet
//
//  Created by Gonçalo on 20/01/2024.
//

import SwiftUI

extension Color {
    static let systemBackground = Color("systemBackground")
    
    private static let colorMap: [String: Color] = [
        "clear": .clear,
        "black": .black,
        "white": .white,
        "gray": .gray,
        "red": .red,
        "green": .green,
        "blue": .blue,
        "orange": .orange,
        "yellow": .yellow,
        "pink": .pink,
        "purple": .purple,
        "primary": .primary,
        "secondary": .secondary,
        "systemBackground": Color(uiColor: .systemBackground),
        "inversedSystemBackground": Color(uiColor: .inverseSystemBackground)
    ]

    init(_ name: String) {
        self = Color.colorMap[name, default: .clear]
    }
    
    var name: String {
        Color.colorMap.first(where: { $1 == self })?.key ?? "clear"
    }
}
