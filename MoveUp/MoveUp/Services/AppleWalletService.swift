import Foundation
import PassKit
import UIKit
import SwiftUI

// MARK: - Apple Wallet Service
class AppleWalletService: NSObject {
    static let shared = AppleWalletService()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Availability Check
    
    /// Verifica se Apple Wallet è disponibile sul dispositivo
    func isWalletAvailable() -> Bool {
        return PKAddPassesViewController.canAddPasses()
    }
    
    // MARK: - Pass Generation
    
    /// Genera un pass per una lezione prenotata
    func generateLessonPass(
        booking: Booking,
        lesson: Lesson,
        instructor: Instructor,
        completion: @escaping (Result<PKPass, WalletError>) -> Void
    ) {
        // In produzione, questo richiamerebbe un endpoint backend che genera il .pkpass
        // Per ora creiamo dati mock per il pass
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Simula chiamata API
            Thread.sleep(forTimeInterval: 1.0)
            
            // In produzione: il backend restituirebbe i dati del .pkpass firmato
            // let passData = try? Data(contentsOf: backendURL)
            
            // Mock: per ora generiamo un errore perché serve un certificato Apple
            let mockError = WalletError.passCreationFailed("Certificato Apple Wallet non configurato. Contatta lo sviluppatore.")
            
            DispatchQueue.main.async {
                completion(.failure(mockError))
            }
        }
    }
    
    // MARK: - Pass Presentation
    
    /// Mostra il controller per aggiungere il pass al Wallet
    func presentAddPassViewController(
        pass: PKPass,
        from viewController: UIViewController,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard let addPassVC = PKAddPassesViewController(pass: pass) else {
            completion?(false)
            return
        }
        
        addPassVC.delegate = PassViewControllerDelegate.shared
        PassViewControllerDelegate.shared.completion = completion
        
        viewController.present(addPassVC, animated: true)
    }
    
    // MARK: - Pass Updates
    
    /// Aggiorna un pass esistente nel Wallet
    func updatePass(
        passTypeIdentifier: String,
        serialNumber: String,
        updates: [String: Any],
        completion: @escaping (Result<Void, WalletError>) -> Void
    ) {
        // In produzione, questo invierebbe una notifica push al pass
        // tramite Apple Push Notification Service (APNs)
        
        DispatchQueue.global(qos: .userInitiated).async {
            Thread.sleep(forTimeInterval: 0.5)
            
            // Mock success
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Pass Removal
    
    /// Verifica se un pass specifico è presente nel Wallet
    func isPassInWallet(passTypeIdentifier: String, serialNumber: String) -> Bool {
        let passLibrary = PKPassLibrary()
        let passes = passLibrary.passes()
        return passes.contains { pass in
            pass.passTypeIdentifier == passTypeIdentifier && pass.serialNumber == serialNumber
        }
    }
    
    /// Rimuove un pass dal Wallet (l'utente deve farlo manualmente)
    func removePassFromWallet(pass: PKPass) {
        let passLibrary = PKPassLibrary()
        passLibrary.removePass(pass)
    }
}

// MARK: - Pass View Controller Delegate
class PassViewControllerDelegate: NSObject, PKAddPassesViewControllerDelegate {
    static let shared = PassViewControllerDelegate()
    var completion: ((Bool) -> Void)?
    
    func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
        controller.dismiss(animated: true) {
            self.completion?(true)
            self.completion = nil
        }
    }
}

// MARK: - Wallet Error
enum WalletError: LocalizedError {
    case walletNotAvailable
    case passCreationFailed(String)
    case passNotFound
    case networkError(String)
    case certificateError
    
    var errorDescription: String? {
        switch self {
        case .walletNotAvailable:
            return "Apple Wallet non è disponibile su questo dispositivo"
        case .passCreationFailed(let reason):
            return "Impossibile creare il pass: \(reason)"
        case .passNotFound:
            return "Pass non trovato nel Wallet"
        case .networkError(let message):
            return "Errore di rete: \(message)"
        case .certificateError:
            return "Certificato Apple Wallet non configurato"
        }
    }
}

// MARK: - Pass Template Data
struct LessonPassData {
    let passTypeIdentifier = "pass.com.moveup.lesson"
    let teamIdentifier = "YOUR_TEAM_ID" // Da configurare
    
    let bookingId: String
    let lessonTitle: String
    let instructorName: String
    let date: Date
    let time: String
    let location: String
    let sport: String
    let price: Double
    
    var serialNumber: String {
        return "LESSON-\(bookingId)"
    }
    
    var primaryField: PassField {
        PassField(
            key: "sport",
            label: "Sport",
            value: sport
        )
    }
    
    var secondaryFields: [PassField] {
        [
            PassField(key: "instructor", label: "Istruttore", value: instructorName),
            PassField(key: "date", label: "Data", value: formatDate(date))
        ]
    }
    
    var auxiliaryFields: [PassField] {
        [
            PassField(key: "time", label: "Ora", value: time),
            PassField(key: "location", label: "Luogo", value: location)
        ]
    }
    
    var backFields: [PassField] {
        [
            PassField(key: "price", label: "Prezzo", value: "€\(String(format: "%.2f", price))"),
            PassField(key: "bookingId", label: "ID Prenotazione", value: bookingId),
            PassField(key: "terms", label: "Termini e Condizioni", value: "Cancellazione gratuita fino a 24h prima. MoveUp si riserva il diritto di modificare o cancellare la lezione.")
        ]
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
}

struct PassField {
    let key: String
    let label: String
    let value: String
}

// MARK: - SwiftUI Helper
extension View {
    /// Aggiunge il pulsante "Aggiungi a Wallet" alla view
    @ViewBuilder
    func addToWalletButton(
        isLoading: Binding<Bool>,
        action: @escaping () -> Void
    ) -> some View {
        self.overlay(alignment: .bottom) {
            Button(action: action) {
                HStack(spacing: 8) {
                    if isLoading.wrappedValue {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "wallet.pass.fill")
                            .font(.body)
                    }
                    
                    Text(isLoading.wrappedValue ? "Creazione Pass..." : "Aggiungi a Wallet")
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(12)
            }
            .disabled(isLoading.wrappedValue)
            .padding()
        }
    }
}

// MARK: - Apple Wallet Button (Official Style)
struct AppleWalletButton: View {
    let action: () -> Void
    @Binding var isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "wallet.pass.fill")
                        .font(.title3)
                }
                
                Text(isLoading ? "Creazione..." : "Aggiungi a Wallet")
                    .font(MoveUpFont.body())
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.black)
            .cornerRadius(12)
        }
        .disabled(isLoading || !AppleWalletService.shared.isWalletAvailable())
    }
}

// MARK: - Usage Example (Comment)
/*
 
 // Come usare Apple Wallet Service nelle view:
 
 struct BookingDetailView: View {
     @State private var isCreatingPass = false
     @State private var showError = false
     @State private var errorMessage = ""
     
     let booking: Booking
     let lesson: Lesson
     let instructor: Instructor
     
     var body: some View {
         VStack {
             // ... contenuto dettaglio prenotazione
             
             AppleWalletButton(action: addToWallet, isLoading: $isCreatingPass)
                 .padding()
         }
         .alert("Errore", isPresented: $showError) {
             Button("OK", role: .cancel) { }
         } message: {
             Text(errorMessage)
         }
     }
     
     private func addToWallet() {
         guard AppleWalletService.shared.isWalletAvailable() else {
             errorMessage = "Apple Wallet non disponibile"
             showError = true
             return
         }
         
         isCreatingPass = true
         
         AppleWalletService.shared.generateLessonPass(
             booking: booking,
             lesson: lesson,
             instructor: instructor
         ) { result in
             isCreatingPass = false
             
             switch result {
             case .success(let pass):
                 // Mostra il controller per aggiungere il pass
                 if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let rootVC = windowScene.windows.first?.rootViewController {
                     AppleWalletService.shared.presentAddPassViewController(
                         pass: pass,
                         from: rootVC
                     ) { success in
                         if success {
                             print("✅ Pass aggiunto al Wallet")
                         }
                     }
                 }
                 
             case .failure(let error):
                 errorMessage = error.localizedDescription
                 showError = true
             }
         }
     }
 }
 
 */
