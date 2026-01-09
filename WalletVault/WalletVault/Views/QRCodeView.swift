//
//  QRCodeView.swift
//  WalletVault
//
//  Created by Gonçalo on 24/02/2024.
//

import SwiftUI
import UIKit

struct QRCodeView: View {
    var qrCodeImage: UIImage?
    
    var body: some View {
        if let qrCodeImage = qrCodeImage {
            Image(uiImage: qrCodeImage)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
        }
    }
}
