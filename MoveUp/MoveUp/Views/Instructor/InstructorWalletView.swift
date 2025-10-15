//
//  InstructorWalletView.swift
//  MoveUp
//
//  Created by MoveUp on 20/10/2025.
//

import SwiftUI

struct InstructorWalletView: View {
    @State private var monthlyEarnings: Double = 1840.00
    @State private var totalLessons: Int = 42
    @State private var showTransactionDetail = false
    @State private var selectedTransaction: WalletTransaction?
    @State private var showManageIBAN = false
    
    let transactions = WalletTransaction.sampleInstructorTransactions
    let userIBAN = "IT60 ***123 456" // Ultimi 3 cifre mostrate
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Monthly Earnings Card
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Guadagni Questo Mese")
                                .font(MoveUpFont.body())
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("€")
                                .font(MoveUpFont.title(20))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(String(format: "%.2f", monthlyEarnings))
                                .font(MoveUpFont.title(40))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(totalLessons) lezioni completate")
                            .font(MoveUpFont.caption())
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.moveUpPrimary)
                    .cornerRadius(16)
                }
                .padding(.horizontal, MoveUpSpacing.large)
                
                // Auto Payment Info
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color.moveUpAccent1)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pagamenti Automatici")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        Text("Ricevi bonifico settimanale sul tuo IBAN: \(userIBAN)")
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.moveUpAccent1.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, MoveUpSpacing.large)
                
                // Quick Actions
                HStack(spacing: 12) {
                    Button(action: {
                        // Apri storico completo
                    }) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title3)
                            
                            Text("Storico Completo")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color.moveUpPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                    
                    Button(action: {
                        showManageIBAN = true
                    }) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .font(.title3)
                            
                            Text("Gestisci IBAN")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color.moveUpPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, MoveUpSpacing.large)
                
                // Stats Row
                HStack(spacing: 12) {
                    WalletStatCard(
                        title: "Media/Lezione",
                        value: "€ 44",
                        icon: "eurosign.circle.fill",
                        color: Color.moveUpAccent1
                    )
                    
                    WalletStatCard(
                        title: "Prossimo Bonifico",
                        value: "Venerdì",
                        icon: "calendar.badge.clock",
                        color: Color.moveUpAccent2
                    )
                }
                .padding(.horizontal, MoveUpSpacing.large)
                
                // Transactions Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Transazioni Recenti")
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(Color.moveUpTextPrimary)
                        .padding(.horizontal, MoveUpSpacing.large)
                    
                    VStack(spacing: 0) {
                        ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 12) {
                                // Date Header
                                Text(formatDateHeader(date))
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(Color.moveUpTextSecondary)
                                    .padding(.horizontal, MoveUpSpacing.large)
                                    .padding(.top, 12)
                                
                                // Transactions for this date
                                ForEach(groupedTransactions[date] ?? [], id: \.id) { transaction in
                                    Button(action: {
                                        selectedTransaction = transaction
                                        showTransactionDetail = true
                                    }) {
                                        InstructorTransactionRow(transaction: transaction)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if transaction.id != (groupedTransactions[date] ?? []).last?.id {
                                        Divider()
                                            .padding(.leading, 70)
                                    }
                                }
                                .padding(.horizontal, MoveUpSpacing.large)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal, MoveUpSpacing.large)
                }
            }
            .padding(.vertical, MoveUpSpacing.large)
        }
        .background(Color.moveUpBackground)
        .navigationBarHidden(true)
        .sheet(isPresented: $showManageIBAN) {
            ManageIBANView(currentIBAN: userIBAN)
        }
        .sheet(isPresented: $showTransactionDetail) {
            if let transaction = selectedTransaction {
                InstructorTransactionDetailView(transaction: transaction)
            }
        }
    }
    
    private var groupedTransactions: [Date: [WalletTransaction]] {
        Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Oggi"
        } else if calendar.isDateInYesterday(date) {
            return "Ieri"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "it_IT")
            formatter.dateFormat = "d MMMM yyyy"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Wallet Stat Card
struct WalletStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(MoveUpFont.title(20))
                .fontWeight(.bold)
                .foregroundColor(Color.moveUpTextPrimary)
            
            Text(title)
                .font(MoveUpFont.caption())
                .foregroundColor(Color.moveUpTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Manage IBAN View
struct ManageIBANView: View {
    @Environment(\.dismiss) private var dismiss
    let currentIBAN: String
    
    @State private var fullName = "Marco Santini"
    @State private var iban = "IT60 X054 2811 1010 0000 0123 456"
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("IBAN Verificato")
                            .font(MoveUpFont.title())
                            .fontWeight(.bold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        Text("I bonifici vengono inviati automaticamente ogni settimana")
                            .font(MoveUpFont.body())
                            .foregroundColor(Color.moveUpTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                    
                    // IBAN Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dati Bancari")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        VStack(spacing: 12) {
                            // Nome
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nome Intestatario")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(Color.moveUpTextSecondary)
                                
                                TextField("Nome e Cognome", text: $fullName)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                            }
                            
                            // IBAN
                            VStack(alignment: .leading, spacing: 8) {
                                Text("IBAN")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(Color.moveUpTextSecondary)
                                
                                TextField("IT60 X054 2811 1010 0000 0123 456", text: $iban)
                                    .keyboardType(.default)
                                    .autocapitalization(.allCharacters)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    
                    // Save Button
                    Button(action: {
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }) {
                        Text("Salva Modifiche")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.moveUpPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Gestisci IBAN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("Chiudi")
                        }
                        .foregroundColor(Color.moveUpPrimary)
                    }
                }
            }
            .alert("IBAN Aggiornato!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Il tuo IBAN è stato aggiornato con successo!")
            }
        }
    }
}

// MARK: - Instructor Transaction Row
struct InstructorTransactionRow: View {
    let transaction: WalletTransaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextPrimary)
                
                Text(transaction.subtitle)
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(MoveUpFont.body())
                    .fontWeight(.semibold)
                    .foregroundColor(amountColor)
                
                Text(formatTime(transaction.date))
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
            }
        }
        .padding(.vertical, 12)
    }
    
    private var iconName: String {
        switch transaction.type {
        case .earning:
            return "arrow.down.left"
        case .withdrawal:
            return "arrow.up.right"
        case .refund:
            return "arrow.uturn.backward"
        }
    }
    
    private var iconColor: Color {
        switch transaction.type {
        case .earning:
            return Color.green
        case .withdrawal:
            return Color.moveUpPrimary
        case .refund:
            return Color.orange
        }
    }
    
    private var iconBackgroundColor: Color {
        switch transaction.type {
        case .earning:
            return Color.green.opacity(0.1)
        case .withdrawal:
            return Color.moveUpPrimary.opacity(0.1)
        case .refund:
            return Color.orange.opacity(0.1)
        }
    }
    
    private var amountColor: Color {
        switch transaction.type {
        case .earning:
            return Color.green
        case .withdrawal:
            return Color.moveUpTextPrimary
        case .refund:
            return Color.orange
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Instructor Transaction Detail View
struct InstructorTransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let transaction: WalletTransaction
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Transaction Icon & Amount
                    VStack(spacing: 16) {
                        Circle()
                            .fill(iconBackgroundColor)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: iconName)
                                    .font(.system(size: 36))
                                    .foregroundColor(iconColor)
                            )
                        
                        Text(transaction.formattedAmount)
                            .font(MoveUpFont.title(40))
                            .fontWeight(.bold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        Text(transaction.title)
                            .font(MoveUpFont.body())
                            .foregroundColor(Color.moveUpTextSecondary)
                    }
                    .padding(.top, 20)
                    
                    // Transaction Details
                    VStack(spacing: 0) {
                        DetailRow(label: "Tipo", value: transaction.type.displayName)
                        Divider().padding(.leading, 16)
                        DetailRow(label: "Data", value: formatFullDate(transaction.date))
                        Divider().padding(.leading, 16)
                        DetailRow(label: "Ora", value: formatTime(transaction.date))
                        Divider().padding(.leading, 16)
                        DetailRow(label: "Descrizione", value: transaction.subtitle)
                        
                        if let reference = transaction.reference {
                            Divider().padding(.leading, 16)
                            DetailRow(label: "Riferimento", value: reference)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    
                    // Help
                    if transaction.type == .earning {
                        HStack(spacing: 12) {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(Color.moveUpAccent1)
                            
                            Text("Hai un problema con questa transazione? Contatta il supporto.")
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpTextSecondary)
                        }
                        .padding()
                        .background(Color.moveUpAccent1.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Dettagli Transazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Chiudi")
                            .foregroundColor(Color.moveUpPrimary)
                    }
                }
            }
        }
    }
    
    private var iconName: String {
        switch transaction.type {
        case .earning:
            return "arrow.down.left"
        case .withdrawal:
            return "arrow.up.right"
        case .refund:
            return "arrow.uturn.backward"
        }
    }
    
    private var iconColor: Color {
        switch transaction.type {
        case .earning:
            return Color.green
        case .withdrawal:
            return Color.moveUpPrimary
        case .refund:
            return Color.orange
        }
    }
    
    private var iconBackgroundColor: Color {
        switch transaction.type {
        case .earning:
            return Color.green.opacity(0.1)
        case .withdrawal:
            return Color.moveUpPrimary.opacity(0.1)
        case .refund:
            return Color.orange.opacity(0.1)
        }
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(MoveUpFont.body())
                .foregroundColor(Color.moveUpTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(MoveUpFont.body())
                .fontWeight(.medium)
                .foregroundColor(Color.moveUpTextPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
}

// MARK: - Models
struct WalletTransaction: Identifiable {
    let id = UUID()
    let type: TransactionType
    let title: String
    let subtitle: String
    let amount: Double
    let date: Date
    let reference: String?
    
    var formattedAmount: String {
        let sign = type == .earning ? "+" : "-"
        return "\(sign) € \(String(format: "%.2f", abs(amount)))"
    }
    
    enum TransactionType {
        case earning
        case withdrawal
        case refund
        
        var displayName: String {
            switch self {
            case .earning: return "Guadagno"
            case .withdrawal: return "Bonifico Automatico"
            case .refund: return "Rimborso"
            }
        }
    }
    
    static let sampleInstructorTransactions: [WalletTransaction] = [
        WalletTransaction(
            type: .earning,
            title: "Lezione di Tennis",
            subtitle: "Mario Rossi",
            amount: 45.00,
            date: Date(),
            reference: "TRX001234"
        ),
        WalletTransaction(
            type: .earning,
            title: "Lezione di Fitness",
            subtitle: "Giulia Verdi",
            amount: 40.00,
            date: Date().addingTimeInterval(-3600),
            reference: "TRX001235"
        ),
        WalletTransaction(
            type: .withdrawal,
            title: "Bonifico Automatico",
            subtitle: "IT60 ***123 456",
            amount: 500.00,
            date: Date().addingTimeInterval(-86400),
            reference: "PAY123456"
        ),
        WalletTransaction(
            type: .earning,
            title: "Lezione di Tennis",
            subtitle: "Luca Bianchi",
            amount: 45.00,
            date: Date().addingTimeInterval(-86400 * 1),
            reference: "TRX001236"
        ),
        WalletTransaction(
            type: .earning,
            title: "Lezione di Tennis",
            subtitle: "Anna Neri",
            amount: 45.00,
            date: Date().addingTimeInterval(-86400 * 1.5),
            reference: "TRX001237"
        ),
        WalletTransaction(
            type: .refund,
            title: "Rimborso Lezione",
            subtitle: "Cancellazione",
            amount: 45.00,
            date: Date().addingTimeInterval(-86400 * 2),
            reference: "RFD987654"
        ),
        WalletTransaction(
            type: .earning,
            title: "Lezione di Fitness",
            subtitle: "Marco Ferrari",
            amount: 40.00,
            date: Date().addingTimeInterval(-86400 * 2),
            reference: "TRX001238"
        ),
        WalletTransaction(
            type: .earning,
            title: "Lezione di Tennis",
            subtitle: "Sofia Conti",
            amount: 45.00,
            date: Date().addingTimeInterval(-86400 * 3),
            reference: "TRX001239"
        )
    ]
}

struct InstructorWalletView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InstructorWalletView()
        }
    }
}
