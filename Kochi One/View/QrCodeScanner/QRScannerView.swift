//
//  QRScannerView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    // We keep all necessary states, including those for scanning and animation
    @Binding var showQRScanner: Bool   // REQUIRED ARGUMENT 1
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: AppTab // Assuming AppTab is the correct type from the previous context
    @State private var isScanning = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAnimating = false
    @State private var scannerScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    
    // The placeholder frame height remains the same
    private let cameraHeight: CGFloat = 300
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            
            // Title
            Text("Scan QR Code")
                .font(.headline)
                .padding(.vertical, 12)
            
            // Scanner Container
            ZStack {
                // Camera View (The fix is here: using the representable view)
                QRCodeScannerRepresentable(
                    isScanning: $isScanning,
                    completion: { result in
                        switch result {
                        case .success(let code):
                            handleScannedCode(code)
                        case .failure(let error):
                            showError(error.localizedDescription)
                        }
                    })
                    .frame(height: cameraHeight)
                
                // Enhanced Scanner Frame
                ZStack {
                    // Glowing background
                    Rectangle()
                        .strokeBorder(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .background(
                            Rectangle()
                                .stroke(Color.blue.opacity(glowOpacity), lineWidth: 2)
                                .blur(radius: 6)
                        )
                    
                    // Main scanner frame
                    Rectangle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(scannerScale)
                }
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: scannerScale
                )
                
                // Scanning line with gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .blue.opacity(0),
                                .blue.opacity(0.5),
                                .blue.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 180, height: 2)
                    .offset(y: isAnimating ? (cameraHeight / 2 - 20) : -(cameraHeight / 2 - 20))
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 12)
            
            // Instructions
            VStack(spacing: 8) {
                Text("Point your camera at a QR code")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .opacity(isAnimating ? 1 : 0.7)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("QR code will be scanned automatically")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            
            Spacer()
        }
        .onAppear {
            isScanning = true
            isAnimating = true
            
            // Multiple animations
            withAnimation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                scannerScale = 1.02
                glowOpacity = 0.8
            }
        }
        .onDisappear {
            isScanning = false
        }
        .alert("Scan Error", isPresented: $showAlert) {
            Button("OK") { showQRScanner = false }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleScannedCode(_ code: String) {
        isScanning = false // Stop scan upon success
        // Implement your logic here: e.g., navigate to a menu
    }
    
    private func showError(_ message: String) {
        isScanning = false
        alertMessage = message
        showAlert = true
    }
}

// MARK: - AVFoundation Integration

// AVFoundation QR Scanner
struct QRCodeScannerRepresentable: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    let completion: (Result<String, Error>) -> Void
    
    func makeUIViewController(context: Context) -> QRCodeScannerController {
        let controller = QRCodeScannerController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, QRCodeScannerControllerDelegate {
        let completion: (Result<String, Error>) -> Void
        
        init(completion: @escaping (Result<String, Error>) -> Void) {
            self.completion = completion
        }
        
        func qrCodeScanner(_ controller: QRCodeScannerController, didScan code: String) {
            // To ensure the UI updates correctly on success
            DispatchQueue.main.async {
                self.completion(.success(code))
            }
        }
        
        func qrCodeScanner(_ controller: QRCodeScannerController, didFailWith error: Error) {
            // To ensure the UI updates correctly on failure
            DispatchQueue.main.async {
                self.completion(.failure(error))
            }
        }
    }
}

// QR Scanner Controller Protocol
protocol QRCodeScannerControllerDelegate: AnyObject {
    func qrCodeScanner(_ controller: QRCodeScannerController, didScan code: String)
    func qrCodeScanner(_ controller: QRCodeScannerController, didFailWith error: Error)
}

// QR Scanner Controller
class QRCodeScannerController: UIViewController {
    weak var delegate: QRCodeScannerControllerDelegate?
    private var captureSession: AVCaptureSession?
    private let metadataOutput = AVCaptureMetadataOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer? // Store the preview layer
    
    // Flag to prevent redundant setup
    private var isSessionSetup = false
    
    // --- FIX 1: Move setup to viewDidLayoutSubviews ---
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure the preview layer frame matches the host view's final bounds
        // This is crucial for fixing the "black screen" issue
        previewLayer?.frame = view.layer.bounds
        
        // Setup the session only once
        if !isSessionSetup {
            setupCaptureSession()
            isSessionSetup = true
            // Start scanning immediately after successful setup
            startScanning()
        }
    }
    
    private func setupCaptureSession() {
        // Only set up if we don't already have a session
        guard captureSession == nil else { return }
        
        let session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.qrCodeScanner(self, didFailWith: NSError(domain: "AVFoundation", code: 1, userInfo: [NSLocalizedDescriptionKey: "No video device available."]))
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                return
            }
        } catch {
            delegate?.qrCodeScanner(self, didFailWith: error)
            return
        }
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        // --- FIX 2: Create and configure the preview layer correctly ---
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        // Set the frame now, and it will be updated in viewDidLayoutSubviews()
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        // Add the layer as a sublayer
        view.layer.addSublayer(previewLayer)
        
        self.captureSession = session
        self.previewLayer = previewLayer
    }
    
    // ... (rest of startScanning, stopScanning, and extension remains the same)
    
    func startScanning() {
        // Only start if the session exists and is not already running
        if captureSession?.isRunning == false {
            // Must be called on a background thread
            DispatchQueue.global(qos: .background).async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    func stopScanning() {
        // Only stop if running
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
}

// ... (AVCaptureMetadataOutputObjectsDelegate extension remains the same)

extension QRCodeScannerController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            stopScanning()
            delegate?.qrCodeScanner(self, didScan: stringValue)
        }
    }
}
