//
//  ShareUIActivityController.swift
//  WalletVault
//
//  Created by Gonçalo on 24/02/2024.
//

import SwiftUI
import UIKit

struct ShareUIActivityController: UIViewControllerRepresentable {
    var shareItems: [Any]
    var applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
