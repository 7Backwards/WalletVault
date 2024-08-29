//
//  QRCodeScannerView.swift
//  SafeWallet
//
//  Created by Gonçalo on 24/02/2024.
//

import SwiftUI
import AVFoundation

fileprivate let qrCodeMaxHeight: CGFloat = 340

struct QRCodeScannerView: View {
    @ObservedObject var viewModel: CardListViewModel
    @State private var manualCode: String = ""
    @State private var isCodeEntryVisible: Bool = false
    private let qrCodeAlignmentFrameCornerRadius: CGFloat = 16

    var body: some View {
        VStack(spacing: 20) {
            Text("Scan the QR Code or Enter the Code Manually")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()

            QRCodeScannerUIView { string in
                processScannedCode(string)
            }
            .frame(maxHeight: qrCodeMaxHeight)
            .cornerRadius(12)
            .shadow(radius: 10)
            .overlay(
                RoundedRectangle(cornerRadius: qrCodeAlignmentFrameCornerRadius)
                    .strokeBorder(style: StrokeStyle(lineWidth: 4, dash: [10]))
                    .foregroundColor(.blue)
                    .padding(50)
            )

            if isCodeEntryVisible {
                VStack(spacing: 20) {
                    HStack {
                        TextField("Enter Code", text: $manualCode)
                            .textFieldStyle(.plain)

                        Button(action: {
                            if let clipboardContent = UIPasteboard.general.string {
                                manualCode = clipboardContent
                            }
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )

                    Button(action: {
                        processScannedCode(manualCode)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text("Submit Code")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: viewModel.appManager.constants.qrCodeSize.width)
                .transition(.move(edge: .bottom))
            } else {
                Button(action: {
                    withAnimation {
                        isCodeEntryVisible.toggle()
                    }
                }) {
                    Text("Enter Code Manually")
                        .foregroundColor(.blue)
                        .underline()
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal, 16)
    }

    private func processScannedCode(_ code: String) {
        viewModel.activeShareSheet = nil
        guard let cardInfo = viewModel.appManager.utils.parseCardInfo(from: code, using: viewModel.appManager.constants.encryptionKey) else {
            Logger.log("Error getting parsed card info", level: .error)
            return
        }
        let cardObject = CardObservableObject(cardInfo: cardInfo)
        viewModel.addOrEdit(cardObject: cardObject) { result in
            switch result {
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.viewModel.activeAlert = .cardAdded
                }
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.viewModel.activeAlert = .error
                }
            }
        }
    }
}



struct QRCodeScannerUIView: UIViewControllerRepresentable {
    var completion: ((String) -> Void)?
    var captureSession: AVCaptureSession?
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerUIView
        var captureSession: AVCaptureSession?
        
        init(parent: QRCodeScannerUIView, captureSession: AVCaptureSession?) {
            self.parent = parent
            self.captureSession = captureSession
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                DispatchQueue.main.async {
                    self.parent.captureSession?.stopRunning()
                    self.parent.completion?(stringValue)
                    self.parent.completion = nil
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, captureSession: self.captureSession)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return viewController }
        
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.global())
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return viewController
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        let sideLength = qrCodeMaxHeight
        let viewBounds = viewController.view.bounds
        let previewLayerFrame = CGRect(x: 0,
                                       y: 0,
                                       width: viewBounds.width,
                                       height: sideLength)
        
        previewLayer.frame = previewLayerFrame
        viewController.view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
