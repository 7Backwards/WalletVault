//
//  AppUtils+QrCode.swift
//  SafeWallet
//
//  Created by Gonçalo on 24/02/2024.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit


extension AppUtils {
    func generateCardQRCode(from card: CardInfo) -> UIImage {
        let string = getNonFormattedShareCardInfo(card: card)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
