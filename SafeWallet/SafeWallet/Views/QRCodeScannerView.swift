//
//  QRCodeScannerView.swift
//  SafeWallet
//
//  Created by Gonçalo on 24/02/2024.
//

import SwiftUI
import AVFoundation

struct QRCodeScannerView: View {
    @ObservedObject var viewModel: CardListViewModel
    var body: some View {
        QRCodeScannerUIView() { string in
            viewModel.activeShareSheet = nil
            guard let cardInfo = viewModel.appManager.utils.parseCardInfo(from: string) else {
                // TODO: Add logging
                return
            }
            let cardViewModel = CardViewModel(cardInfo: cardInfo)
            viewModel.addOrEdit(cardViewModel: cardViewModel) { result in
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
        .overlay {
            Rectangle()
                .stroke(lineWidth: 2)
                .foregroundColor(.black)
                .frame(width: 200, height: 200)
                .background(Color.clear)
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
        
        let sideLength = 340.0
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
