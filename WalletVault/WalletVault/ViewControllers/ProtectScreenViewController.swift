//
//  ProtectScreenViewController.swift
//  WalletVault
//
//  Created by Gonçalo on 17/02/2024.
//

import UIKit

class ProtectScreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appIconBackgroundColor
        let imageView = UIImageView(image: UIImage(named: "AppIcon"))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
