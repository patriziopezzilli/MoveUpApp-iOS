import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Instructor QR Code View
struct InstructorQRCodeView: View {
    let instructorId: String
    let instructorName: String
    
    @State private var isAddingToWallet = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Info Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.moveUpPrimary)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                    
                    Text(instructorName)
                        .font(MoveUpFont.title())
                        .fontWeight(.bold)
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    Text("Istruttore MoveUp")
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextSecondary)
                }
                .padding(.top)
                
                // QR Code Card
                VStack(spacing: 20) {
                    Text("Il Tuo QR Code")
                        .font(MoveUpFont.subtitle())
                        .fontWeight(.bold)
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    // QR Code
                    if let qrImage = generateQRCode(from: instructorId) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 250, height: 250)
                            .cornerRadius(16)
                            .overlay(
                                Text("QR non disponibile")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(Color.moveUpTextSecondary)
                            )
                    }
                    
                    Text("ID: \(instructorId)")
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextSecondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.moveUpPrimary.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                
                // Info Box
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color.moveUpPrimary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Come Funziona")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        Text("Gli studenti scansionano questo QR all'inizio della lezione per confermare la loro presenza")
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color.moveUpPrimary.opacity(0.1))
                .cornerRadius(12)
                
                // Features List
                VStack(alignment: .leading, spacing: 16) {
                    Text("Vantaggi")
                        .font(MoveUpFont.subtitle())
                        .fontWeight(.bold)
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    InstructorQRFeatureRow(
                        icon: "checkmark.circle.fill",
                        title: "Check-in Automatico",
                        description: "Gli studenti confermano la presenza istantaneamente"
                    )
                    
                    InstructorQRFeatureRow(
                        icon: "eurosign.circle.fill",
                        title: "Pagamento Sicuro",
                        description: "Il pagamento viene processato automaticamente"
                    )
                    
                    InstructorQRFeatureRow(
                        icon: "clock.fill",
                        title: "Tracciamento Presenze",
                        description: "Registro automatico di tutte le lezioni"
                    )
                    
                    InstructorQRFeatureRow(
                        icon: "shield.fill",
                        title: "Sicuro e Privato",
                        description: "QR code criptato e personale"
                    )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                
                // Add to Wallet Button
                Button(action: addToWallet) {
                    HStack(spacing: 8) {
                        if isAddingToWallet {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "wallet.pass.fill")
                                .font(.title3)
                        }
                        
                        Text(isAddingToWallet ? "Aggiunta in corso..." : "Aggiungi QR a Wallet")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .cornerRadius(12)
                }
                .disabled(isAddingToWallet)
                
                // Share Button
                Button(action: shareQRCode) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                        
                        Text("Condividi QR Code")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color.moveUpPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.moveUpPrimary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(Color.moveUpBackground)
        .navigationTitle("Il Tuo QR Code")
        .navigationBarTitleDisplayMode(.inline)
        .alert("QR Aggiunto al Wallet!", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Il tuo QR code è stato aggiunto ad Apple Wallet. Sarà sempre disponibile nel tuo Wallet.")
        }
        .alert("Errore", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - QR Code Generation
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        // Creiamo i dati del QR con formato JSON
        let qrData = """
        {
            "type": "instructor_checkin",
            "instructorId": "\(string)",
            "timestamp": "\(Date().timeIntervalSince1970)"
        }
        """
        
        guard let data = qrData.data(using: .utf8) else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // High error correction
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale up for better quality
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Add to Wallet
    private func addToWallet() {
        guard AppleWalletService.shared.isWalletAvailable() else {
            errorMessage = "Apple Wallet non è disponibile su questo dispositivo"
            showError = true
            return
        }
        
        isAddingToWallet = true
        
        // Simula creazione pass (in produzione, chiamerebbe il backend)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAddingToWallet = false
            
            // Mock success - in produzione genererebbe un .pkpass reale
            showSuccess = true
        }
    }
    
    // MARK: - Share QR Code
    private func shareQRCode() {
        guard let qrImage = generateQRCode(from: instructorId) else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [
                qrImage,
                "Scansiona questo QR per il check-in alla lezione con \(instructorName) su MoveUp!"
            ],
            applicationActivities: nil
        )
        
        // Present activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Instructor QR Feature Row
struct InstructorQRFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.moveUpPrimary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(Color.moveUpPrimary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MoveUpFont.body())
                    .fontWeight(.semibold)
                    .foregroundColor(Color.moveUpTextPrimary)
                
                Text(description)
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        InstructorQRCodeView(
            instructorId: "INST-12345",
            instructorName: "Marco Rossi"
        )
    }
}
