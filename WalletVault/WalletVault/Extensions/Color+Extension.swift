//
//  Color+Extension.swift
//  WalletVault
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
        "appIconBackgroundColor": Color(uiColor: .appIconBackgroundColor),
        "inversedSystemBackground": Color(uiColor: .inverseSystemBackground)
    ]

    init(_ name: String) {
        self = Color.colorMap[name, default: .clear]
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, int >> 24)
        default:
            (r, g, b, a) = (1, 1, 1, 1)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        let uiColor = UIColor(self)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
