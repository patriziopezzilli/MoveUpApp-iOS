//
//  WalletDashboardView.swift
//  MoveUp
//
//  Created on 14/10/2024.
//

import SwiftUI
import Combine

struct WalletDashboardView: View {
    @StateObject private var viewModel = WalletDashboardViewModel()
    @State private var showSetup = false
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Balance Card
                    balanceCard
                    
                    // Quick Actions
                    if viewModel.wallet?.bankAccountSetup == true {
                        quickActionsSection
                    }
                    
                    // Stats
                    statsSection
                    
                    // Recent Transactions
                    transactionsSection
                }
                .padding()
            }
            .navigationTitle("Wallet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showSetup = true }) {
                            Label("Configura IBAN", systemImage: "creditcard")
                        }
                        
                        Button(action: { /* Add to Apple Wallet */ }) {
                            Label("Aggiungi a Wallet", systemImage: "wallet.pass")
                        }
                        
                        Button(action: { viewModel.refresh() }) {
                            Label("Aggiorna", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                WalletSetupView()
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .onAppear {
                viewModel.loadWallet()
            }
        }
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        VStack(spacing: 16) {
            // Balance header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saldo Disponibile")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(viewModel.wallet?.formattedBalance ?? "€0.00")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Bank account info
            if let wallet = viewModel.wallet, wallet.bankAccountSetup {
                Divider()
                    .background(Color.white.opacity(0.3))
                
                HStack {
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(.white.opacity(0.8))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(wallet.accountHolderName ?? "")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text(wallet.maskedIban ?? "")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } else {
                Divider()
                    .background(Color.white.opacity(0.3))
                
                Button(action: { showSetup = true }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        
                        Text("Configura IBAN per ricevere pagamenti")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .padding(20)
        .background(Color.blue)
        .cornerRadius(20)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Azioni Rapide")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "wallet.pass",
                    title: "Apple Wallet",
                    color: .purple
                ) {
                    // Add to Apple Wallet
                }
                
                QuickActionButton(
                    icon: "arrow.down.circle",
                    title: "Prelievo",
                    color: .orange
                ) {
                    // Withdraw funds
                }
                
                QuickActionButton(
                    icon: "doc.text",
                    title: "Fatture",
                    color: .green
                ) {
                    // View invoices
                }
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistiche")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    icon: "eurosign.circle.fill",
                    title: "Guadagno Totale",
                    value: viewModel.wallet?.formattedTotalEarnings ?? "€0.00",
                    color: .green
                )
                
                StatCard(
                    icon: "figure.walk",
                    title: "Lezioni",
                    value: "\(viewModel.wallet?.totalLessons ?? 0)",
                    color: .blue
                )
                
                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Media/Lezione",
                    value: String(format: "€%.2f", viewModel.wallet?.averageLessonPrice ?? 0),
                    color: .orange
                )
                
                StatCard(
                    icon: "arrow.down.circle",
                    title: "Prelevato",
                    value: String(format: "€%.2f", viewModel.wallet?.totalWithdrawn ?? 0),
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Transactions Section
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transazioni Recenti")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: TransactionHistoryView()) {
                    Text("Vedi Tutte")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if viewModel.transactions.isEmpty {
                emptyTransactionsView
            } else {
                ForEach(viewModel.transactions.prefix(5)) { transaction in
                    TransactionRow(transaction: transaction)
                        .onTapGesture {
                            selectedTransaction = transaction
                        }
                }
            }
        }
    }
    
    private var emptyTransactionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Nessuna Transazione")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Le tue transazioni appariranno qui")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: transaction.type.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(transaction.status.color))
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .bold()
                
                Text(transaction.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(transaction.isCredit ? .green : .red)
                
                Text(transaction.status.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - ViewModel
class WalletDashboardViewModel: ObservableObject {
    @Published var wallet: Wallet?
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    
    func loadWallet() {
        isLoading = true
        
        // TODO: Replace with actual API call
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            // Mock data
            let mockWallet = Wallet(
                id: "wallet1",
                userId: "user1",
                balance: 450.0,
                currency: "EUR",
                bankAccountSetup: true,
                maskedIban: "IT60 •••• •••• •••• 3456",
                accountHolderName: "Mario Rossi",
                totalEarnings: 1250.0,
                totalLessons: 24,
                totalWithdrawn: 800.0,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            self?.wallet = mockWallet
            self?.loadTransactions()
            self?.isLoading = false
        }
    }
    
    func loadTransactions() {
        // TODO: Replace with actual API call
        // Mock transactions
        transactions = []
    }
    
    func refresh() {
        loadWallet()
    }
}

// MARK: - Transaction History View (Placeholder)
struct TransactionHistoryView: View {
    var body: some View {
        Text("Transaction History")
            .navigationTitle("Storico Transazioni")
    }
}

// MARK: - Transaction Detail View (Placeholder)
struct TransactionDetailView: View {
    let transaction: Transaction
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Transaction Detail")
                    Text(transaction.description)
                }
                .padding()
            }
            .navigationTitle("Dettaglio")
        }
    }
}

// MARK: - Preview
#Preview {
    WalletDashboardView()
}
