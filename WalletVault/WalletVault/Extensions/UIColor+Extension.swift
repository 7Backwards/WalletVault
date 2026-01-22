//
//  UIColor+Extension.swift
//  WalletVault
//
//  Created by Gonçalo on 17/02/2024.
//

import UIKit
import SwiftUI

extension UIColor {
    @objc static let appIconBackgroundColor: UIColor = .palette(named: "\(#keyPath(UIColor.appIconBackgroundColor))")
}

extension UIColor {
    
    convenience init(hex: String) {
        let color = Color(hex: hex)
        
        self.init(color)
    }

    static func palette(named colorName: String) -> UIColor {
        guard let color = UIColor(named: colorName) else {
            let message = "UIColor \(colorName) not found in application bundle"
            fatalError(message)
        }
        
        return color
    }
    
    var hsbComponents: (hue: Double, saturation: Double, brightness: Double) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return (Double(hue), Double(saturation), Double(brightness))
    }
}
