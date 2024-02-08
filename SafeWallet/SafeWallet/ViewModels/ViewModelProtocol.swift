//
//  ViewModelProtocol.swift
//  SafeWallet
//
//  Created by Gonçalo on 08/02/2024.
//

import Foundation

protocol ViewModelProtocol: ObservableObject {
    var appManager: AppManager { get set }
}
