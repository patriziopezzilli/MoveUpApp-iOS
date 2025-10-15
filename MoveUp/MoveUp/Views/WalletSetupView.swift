//
//  WalletSetupView.swift
//  MoveUp
//
//  Created on 14/10/2024.
//

import SwiftUI
import Combine

struct WalletSetupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = WalletSetupViewModel()
    
    @State private var iban = ""
    @State private var accountHolderName = ""
    @State private var country = "IT"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Collega il tuo Conto Bancario")
                            .font(.title2)
                            .bold()
                        
                        Text("Inserisci il tuo IBAN per ricevere i pagamenti delle lezioni direttamente sul tuo conto")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Account Holder Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nome Intestatario")
                                .font(.subheadline)
                                .bold()
                            
                            TextField("Mario Rossi", text: $accountHolderName)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.words)
                        }
                        
                        // IBAN
                        VStack(alignment: .leading, spacing: 8) {
                            Text("IBAN")
                                .font(.subheadline)
                                .bold()
                            
                            TextField("IT60 X054 2811 1010 0000 0123 456", text: $iban)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.allCharacters)
                                .keyboardType(.default)
                                .onChange(of: iban) { newValue in
                                    // Format IBAN with spaces
                                    iban = formatIban(newValue)
                                }
                            
                            if !iban.isEmpty && !isValidIban(iban) {
                                Label("IBAN non valido", systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else if !iban.isEmpty {
                                Label("IBAN valido", systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Country
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Paese")
                                .font(.subheadline)
                                .bold()
                            
                            Picker("Paese", selection: $country) {
                                Text("🇮🇹 Italia").tag("IT")
                                Text("🇫🇷 Francia").tag("FR")
                                Text("🇩🇪 Germania").tag("DE")
                                Text("🇪🇸 Spagna").tag("ES")
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Security info
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sicuro e Protetto")
                                .font(.subheadline)
                                .bold()
                            
                            Text("I tuoi dati bancari sono criptati e non vengono mai condivisi con terze parti.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // How it works
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Come Funziona")
                            .font(.headline)
                        
                        HStack(alignment: .top, spacing: 12) {
                            Text("1")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Completa una lezione")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("Il cliente conferma la lezione tramite QR code")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Text("2")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pagamento elaborato")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("Il tuo wallet viene accreditato automaticamente")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Text("3")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Trasferimento automatico")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("I soldi arrivano sul tuo conto in 1-3 giorni")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Submit button
                    Button(action: {
                        setupBankAccount()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Collega Conto Bancario")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(canSubmit ? Color.blue : Color.gray)
                    )
                    .disabled(!canSubmit || viewModel.isLoading)
                }
                .padding()
            }
            .navigationTitle("Configura Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            .alert("Errore", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Successo!", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Il tuo conto bancario è stato collegato con successo!")
            }
        }
    }
    
    private var canSubmit: Bool {
        !accountHolderName.isEmpty && isValidIban(iban)
    }
    
    private func setupBankAccount() {
        viewModel.setupBankAccount(
            iban: iban,
            accountHolderName: accountHolderName,
            country: country
        )
    }
    
    private func formatIban(_ input: String) -> String {
        let cleaned = input.replacingOccurrences(of: " ", with: "").uppercased()
        var formatted = ""
        
        for (index, char) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted.append(" ")
            }
            formatted.append(char)
        }
        
        return formatted
    }
    
    private func isValidIban(_ iban: String) -> Bool {
        let cleaned = iban.replacingOccurrences(of: " ", with: "")
        
        // Basic validation: IT IBAN is 27 characters
        if cleaned.hasPrefix("IT") && cleaned.count == 27 {
            return true
        }
        
        // Generic IBAN validation (15-34 characters)
        return cleaned.count >= 15 && cleaned.count <= 34
    }
}

// MARK: - ViewModel
class WalletSetupViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    func setupBankAccount(iban: String, accountHolderName: String, country: String) {
        isLoading = true
        errorMessage = nil
        
        // TODO: Replace with actual API call
        // For now, simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isLoading = false
            self?.showSuccess = true
            
            // Actual implementation:
            // try await APIClient.shared.post("/wallet/setup", body: [
            //     "userId": currentUserId,
            //     "iban": iban,
            //     "accountHolderName": accountHolderName,
            //     "country": country
            // ])
        }
    }
}

// MARK: - Preview
#Preview {
    WalletSetupView()
}
