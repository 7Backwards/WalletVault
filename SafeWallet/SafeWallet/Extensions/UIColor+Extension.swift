//
//  UIColor+Extension.swift
//  SafeWallet
//
//  Created by Gonçalo on 17/02/2024.
//

import UIKit

extension UIColor {
    @objc static let appIconBackgroundColor: UIColor = .palette(named: "\(#keyPath(UIColor.appIconBackgroundColor))")
}

private extension UIColor {
    
    static func palette(named colorName: String) -> UIColor {
        guard let color = UIColor(named: colorName) else {
            let message = "UIColor \(colorName) not found in application bundle"
            fatalError(message)
        }
        
        return color
    }
}
