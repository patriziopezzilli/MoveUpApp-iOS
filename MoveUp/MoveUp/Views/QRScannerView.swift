//
//  QRScannerView.swift
//  MoveUp
//
//  Created by MoveUp Team on 14/10/2025.
//  QR Scanner per validazione lezioni e pagamenti
//

import SwiftUI
import AVFoundation
import Combine

struct QRScannerView: View {
    @StateObject private var viewModel = QRScannerViewModel()
    @Environment(\.dismiss) var dismiss
    
    let booking: Booking
    let onSuccess: (Booking) -> Void
    
    var body: some View {
        ZStack {
            // Camera preview
            QRCodeCameraView(
                isScanning: $viewModel.isScanning,
                onQRCodeDetected: { qrCode in
                    viewModel.validateQRCode(qrCode, for: booking)
                }
            )
            .edgesIgnoringSafeArea(.all)
            
            // Overlay UI
            VStack {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                    
                    // Flashlight toggle
                    Button(action: { viewModel.toggleFlashlight() }) {
                        Image(systemName: viewModel.isFlashlightOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                }
                .padding()
                
                Spacer()
                
                // Scanning frame
                VStack(spacing: 20) {
                    Text("Scansiona il QR Code")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    
                    // Animated scanning frame
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green, lineWidth: 4)
                            .frame(width: 280, height: 280)
                        
                        // Scanning line animation
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .green.opacity(0.8), .clear]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 280, height: 3)
                            .offset(y: viewModel.scanLineOffset)
                        
                        // Corner decorations
                        VStack {
                            HStack {
                                ScannerCorner(rotation: 0)
                                Spacer()
                                ScannerCorner(rotation: 90)
                            }
                            Spacer()
                            HStack {
                                ScannerCorner(rotation: -90)
                                Spacer()
                                ScannerCorner(rotation: 180)
                            }
                        }
                        .frame(width: 280, height: 280)
                    }
                    
                    Text("Inquadra il QR Code dell'istruttore")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(radius: 5)
                }
                
                Spacer()
                
                // Booking info card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Lezione: \(booking.sport ?? "Sport")")
                            .font(.headline)
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.purple)
                        Text("Istruttore: \(booking.instructorName ?? "N/A")")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "eurosign.circle.fill")
                            .foregroundColor(.green)
                        Text("Importo: €\(booking.totalAmount, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            
            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Validazione in corso...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            // Success overlay
            if viewModel.showSuccess {
                Color.green.opacity(0.95)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 10) {
                        Text("Lezione Validata!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Pagamento completato con successo")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    if let result = viewModel.validationResult {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Importo pagato:")
                                Spacer()
                                Text("€\(result.grossAmount, specifier: "%.2f")")
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Fee piattaforma:")
                                Spacer()
                                Text("€\(result.platformFee, specifier: "%.2f")")
                                    .fontWeight(.semibold)
                            }
                            
                            Divider()
                                .background(Color.white)
                            
                            HStack {
                                Text("Accreditato:")
                                Spacer()
                                Text("€\(result.netAmount, specifier: "%.2f")")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                    }
                }
            }
        }
        .alert("Errore", isPresented: $viewModel.showError) {
            Button("OK") { 
                viewModel.errorMessage = nil
                viewModel.isScanning = true
            }
        } message: {
            Text(viewModel.errorMessage ?? "Errore sconosciuto")
        }
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
        .onChange(of: viewModel.showSuccess) { success in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if let validatedBooking = viewModel.validatedBooking {
                        onSuccess(validatedBooking)
                    }
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Scanner Corner Decoration
struct ScannerCorner: View {
    let rotation: Double
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 0))
        }
        .stroke(Color.white, lineWidth: 4)
        .frame(width: 20, height: 20)
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Camera View (AVFoundation)
struct QRCodeCameraView: UIViewRepresentable {
    @Binding var isScanning: Bool
    let onQRCodeDetected: (String) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return view
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            let session = AVCaptureSession()
            session.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            session.addOutput(output)
            
            output.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
            
            context.coordinator.session = session
            context.coordinator.previewLayer = previewLayer
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
            
        } catch {
            print("Error setting up camera: \(error)")
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let previewLayer = context.coordinator.previewLayer {
                previewLayer.frame = uiView.bounds
            }
        }
        
        if isScanning {
            context.coordinator.session?.startRunning()
        } else {
            context.coordinator.session?.stopRunning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onQRCodeDetected: onQRCodeDetected, isScanning: $isScanning)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let onQRCodeDetected: (String) -> Void
        @Binding var isScanning: Bool
        var session: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        
        init(onQRCodeDetected: @escaping (String) -> Void, isScanning: Binding<Bool>) {
            self.onQRCodeDetected = onQRCodeDetected
            self._isScanning = isScanning
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard isScanning else { return }
            
            if let metadataObject = metadataObjects.first,
               let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
               let stringValue = readableObject.stringValue {
                
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                isScanning = false
                onQRCodeDetected(stringValue)
            }
        }
    }
}

// MARK: - View Model
class QRScannerViewModel: ObservableObject {
    @Published var isScanning = true
    @Published var isLoading = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var scanLineOffset: CGFloat = -140
    @Published var isFlashlightOn = false
    @Published var validationResult: ValidationResult?
    @Published var validatedBooking: Booking?
    
    private var scanLineTimer: Timer?
    
    func startScanning() {
        isScanning = true
        startScanLineAnimation()
    }
    
    func stopScanning() {
        isScanning = false
        scanLineTimer?.invalidate()
    }
    
    func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            if isFlashlightOn {
                device.torchMode = .off
                isFlashlightOn = false
            } else {
                try device.setTorchModeOn(level: 1.0)
                isFlashlightOn = true
            }
            device.unlockForConfiguration()
        } catch {
            print("Flashlight error: \(error)")
        }
    }
    
    private func startScanLineAnimation() {
        scanLineTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.linear(duration: 0.02)) {
                if self.scanLineOffset >= 140 {
                    self.scanLineOffset = -140
                } else {
                    self.scanLineOffset += 3
                }
            }
        }
    }
    
    func validateQRCode(_ qrCode: String, for booking: Booking) {
        isLoading = true
        
        // Call validation API
        let request = ValidationRequest(
            bookingId: booking.id,
            qrCodeData: qrCode,
            scannedBy: booking.userId
        )
        
        APIService.shared.validateLesson(request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.validationResult = response.payment
                    self?.validatedBooking = response.booking
                    self?.showSuccess = true
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    self?.isScanning = false
                }
            }
        }
    }
}

// MARK: - Data Models
struct ValidationRequest: Codable {
    let bookingId: String
    let qrCodeData: String
    let scannedBy: String
}

struct ValidationResponse: Codable {
    let success: Bool
    let message: String
    let booking: Booking
    let payment: ValidationResult
}

struct ValidationResult: Codable {
    let paymentIntentId: String
    let transferId: String?
    let transactionId: String
    let grossAmount: Double
    let platformFee: Double
    let netAmount: Double
    let trainerEarning: Double
}

// MARK: - Preview
struct QRScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRScannerView(
            booking: Booking(
                id: "1",
                lessonId: "lesson1",
                instructorId: "instructor1",
                userId: "user1",
                scheduledDate: Date(),
                status: .confirmed,
                paymentStatus: .authorized,
                totalAmount: 50.0,
                notes: nil,
                createdAt: Date(),
                updatedAt: Date(),
                sport: "Tennis",
                instructorName: "Mario Rossi",
                price: 50.0,
                paymentId: "payment1",
                refundId: nil,
                paymentIntentId: "pi_test",
                stripeTransferId: nil,
                validatedAt: nil
            ),
            onSuccess: { _ in }
        )
    }
}
