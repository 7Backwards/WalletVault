//
//  MenuTextView.swift
//  SafeWallet
//
//  Created by Gonçalo on 11/02/2024.
//

import SwiftUI

struct MenuTextView<V: View>: View {
    let content: String
    @Binding var isEditable: Bool
    @State private var showingShareSheet = false
    var view: V
    let showCopy: Bool = true
    let showShare: Bool = true
    let showEdit: Bool = true
    
    var body: some View {
        Menu {
            if showCopy {
                Button(action: {
                    UIPasteboard.general.string = content
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
            if showShare {
                Button(action: {
                    showingShareSheet = true
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            if showEdit {
                Button(action: {
                    isEditable = true
                }) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        } label: {
            view
        }
        .sheet(isPresented: $showingShareSheet, onDismiss: nil) {
            ShareView(shareItems: [content], applicationActivities: nil)
        }
    }
}

struct ShareView: UIViewControllerRepresentable {
    var shareItems: [Any]
    var applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
