//
//  TransactionFeeBreakdownView.swift
//  MoveUp
//
//  Created on 15/10/2025.
//  Mostra breakdown trasparente delle fee di transazione Stripe
//

import SwiftUI

struct TransactionFeeBreakdownView: View {
    let grossAmount: Double
    let showMoveUpMessage: Bool
    
    // Stripe standard pricing EU: 1.5% + €0.25 per transaction
    // https://stripe.com/en-it/pricing
    private var stripeFee: Double {
        return (grossAmount * 0.015) + 0.25
    }
    
    private var netAmount: Double {
        return max(0, grossAmount - stripeFee)
    }
    
    init(grossAmount: Double, showMoveUpMessage: Bool = true) {
        self.grossAmount = grossAmount
        self.showMoveUpMessage = showMoveUpMessage
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.moveUpPrimary)
                
                Text("Breakdown Pagamento")
                    .font(MoveUpFont.subtitle())
                    .foregroundColor(Color.moveUpTextPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Importo lordo (quello che paga il cliente)
                FeeRow(
                    icon: "eurosign.circle.fill",
                    label: "Prezzo lezione",
                    amount: grossAmount,
                    color: Color.moveUpTextPrimary,
                    isBold: false
                )
                
                // Stripe fee (costo transazione)
                FeeRow(
                    icon: "creditcard.fill",
                    label: "Costo transazione",
                    amount: -stripeFee,
                    color: Color.orange,
                    isBold: false,
                    subtitle: "Stripe 1.5% + €0.25"
                )
                
                Divider()
                    .background(Color.black.opacity(0.1))
                    .padding(.vertical, 4)
                
                // Importo netto (quello che riceve l'istruttore)
                FeeRow(
                    icon: "checkmark.circle.fill",
                    label: "Ricevi tu",
                    amount: netAmount,
                    color: Color.moveUpSecondary,
                    isBold: true
                )
            }
            .padding(16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            
            // MoveUp non trattiene nulla
            if showMoveUpMessage {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.moveUpPrimary)
                    
                    Text("MoveUp non trattiene commissioni")
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextSecondary)
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.moveUpPrimary.opacity(0.08))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.moveUpPrimary.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Fee Row Component
struct FeeRow: View {
    let icon: String
    let label: String
    let amount: Double
    let color: Color
    let isBold: Bool
    var subtitle: String? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(isBold ? MoveUpFont.body().bold() : MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextSecondary)
                }
            }
            
            Spacer()
            
            Text(String(format: "%+.2f €", amount))
                .font(isBold ? MoveUpFont.body().bold() : MoveUpFont.body())
                .foregroundColor(color)
        }
    }
}

// MARK: - Compact Version (per usare in cards piccole)
struct CompactFeeBreakdownView: View {
    let grossAmount: Double
    
    private var stripeFee: Double {
        return (grossAmount * 0.015) + 0.25
    }
    
    private var netAmount: Double {
        return max(0, grossAmount - stripeFee)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Gross amount
            VStack(alignment: .leading, spacing: 2) {
                Text("Prezzo")
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
                Text(String(format: "%.2f €", grossAmount))
                    .font(MoveUpFont.body().bold())
                    .foregroundColor(Color.moveUpTextPrimary)
            }
            
            Image(systemName: "arrow.right")
                .font(.system(size: 12))
                .foregroundColor(Color.moveUpTextSecondary)
            
            // Fee
            VStack(alignment: .leading, spacing: 2) {
                Text("Fee")
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
                Text(String(format: "-%.2f €", stripeFee))
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.orange)
            }
            
            Image(systemName: "arrow.right")
                .font(.system(size: 12))
                .foregroundColor(Color.moveUpTextSecondary)
            
            // Net amount
            VStack(alignment: .leading, spacing: 2) {
                Text("Ricevi")
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
                Text(String(format: "%.2f €", netAmount))
                    .font(MoveUpFont.body().bold())
                    .foregroundColor(Color.moveUpSecondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct TransactionFeeBreakdownView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            // Full version
            TransactionFeeBreakdownView(grossAmount: 50.0)
            
            // Without MoveUp message
            TransactionFeeBreakdownView(grossAmount: 30.0, showMoveUpMessage: false)
            
            // Compact version
            CompactFeeBreakdownView(grossAmount: 50.0)
        }
        .padding()
    }
}
