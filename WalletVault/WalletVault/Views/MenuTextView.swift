//
//  MenuTextView.swift
//  WalletVault
//
//  Created by Gonçalo on 11/02/2024.
//

import SwiftUI

struct MenuTextView<V: View>: View {
    let content: String
    @Binding var isEditable: Bool
    @State private var showingShareSheet = false
    var isUnlocked: Bool
    var view: V
    let showCopy: Bool = true
    let showShare: Bool = true
    let showEdit: Bool = true
    
    var body: some View {
        if isUnlocked {
            Menu {
                if showCopy {
                    Button(action: {
                        UIPasteboard.general.string = content
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .glassEffect()
                }
                if showShare {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .glassEffect()
                }
                if showEdit {
                    Button(action: {
                        isEditable = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .glassEffect()
                }
            } label: {
                view
            }
            .sheet(isPresented: $showingShareSheet, onDismiss: nil) {
                ShareUIActivityController(shareItems: [content], applicationActivities: nil)
            }
        } else {
            view
        }
    }
}
