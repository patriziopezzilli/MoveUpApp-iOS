//
//  Transaction.swift
//  MoveUp
//
//  Created on 14/10/2024.
//

import Foundation

struct Transaction: Codable, Identifiable {
    let id: String
    let walletId: String
    
    enum TransactionType: String, Codable {
        case lessonPayment = "LESSON_PAYMENT"
        case payout = "PAYOUT"
        case refund = "REFUND"
        case adjustment = "ADJUSTMENT"
        case bonus = "BONUS"
        
        var displayName: String {
            switch self {
            case .lessonPayment: return "Pagamento Lezione"
            case .payout: return "Prelievo"
            case .refund: return "Rimborso"
            case .adjustment: return "Aggiustamento"
            case .bonus: return "Bonus"
            }
        }
        
        var icon: String {
            switch self {
            case .lessonPayment: return "eurosign.circle.fill"
            case .payout: return "arrow.down.circle.fill"
            case .refund: return "arrow.uturn.backward.circle.fill"
            case .adjustment: return "wrench.and.screwdriver.fill"
            case .bonus: return "gift.fill"
            }
        }
    }
    
    let type: TransactionType
    let amount: Double
    let currency: String = "EUR"
    
    // Description
    let description: String
    var notes: String?
    
    // References
    var bookingId: String?
    var customerId: String?
    var customerName: String?
    
    // Fee breakdown
    var grossAmount: Double?       // Total lesson price (e.g., €50)
    var platformFee: Double?       // Platform fee (e.g., €5)
    var netAmount: Double          // Amount to trainer (e.g., €45)
    
    var feePercentage: Double? {
        guard let gross = grossAmount, gross > 0, let fee = platformFee else { return nil }
        return (fee / gross) * 100
    }
    
    // Stripe references
    var stripeTransferId: String?
    var stripePaymentIntentId: String?
    var stripePayoutId: String?
    
    enum TransactionStatus: String, Codable {
        case pending = "PENDING"
        case processing = "PROCESSING"
        case completed = "COMPLETED"
        case failed = "FAILED"
        case refunded = "REFUNDED"
        case cancelled = "CANCELLED"
        
        var displayName: String {
            switch self {
            case .pending: return "In Attesa"
            case .processing: return "In Elaborazione"
            case .completed: return "Completato"
            case .failed: return "Fallito"
            case .refunded: return "Rimborsato"
            case .cancelled: return "Annullato"
            }
        }
        
        var color: String {
            switch self {
            case .pending, .processing: return "orange"
            case .completed: return "green"
            case .failed, .cancelled: return "red"
            case .refunded: return "blue"
            }
        }
    }
    
    var status: TransactionStatus = .pending
    
    // Timestamps
    let createdAt: Date
    var completedAt: Date?
    var failedAt: Date?
    
    // Computed properties
    var formattedAmount: String {
        let sign = type == .payout ? "-" : "+"
        return "\(sign)€\(String(format: "%.2f", amount))"
    }
    
    var formattedGrossAmount: String? {
        guard let gross = grossAmount else { return nil }
        return "€\(String(format: "%.2f", gross))"
    }
    
    var formattedNetAmount: String {
        "€\(String(format: "%.2f", netAmount))"
    }
    
    var formattedPlatformFee: String? {
        guard let fee = platformFee else { return nil }
        return "€\(String(format: "%.2f", fee))"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var isCredit: Bool {
        type == .lessonPayment || type == .bonus || type == .refund
    }
    
    var isDebit: Bool {
        type == .payout
    }
}

// MARK: - Transaction History Response
struct TransactionHistoryResponse: Codable {
    let transactions: [Transaction]
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool
}

// MARK: - Fee Breakdown
struct FeeBreakdown: Codable {
    let grossAmount: Double      // Prezzo pagato dal customer
    let platformFee: Double      // Fee trattenuta dalla piattaforma
    let netAmount: Double        // Importo al trainer
    let feePercentage: Double    // % fee
    
    var formattedGross: String {
        "€\(String(format: "%.2f", grossAmount))"
    }
    
    var formattedFee: String {
        "€\(String(format: "%.2f", platformFee))"
    }
    
    var formattedNet: String {
        "€\(String(format: "%.2f", netAmount))"
    }
    
    var formattedPercentage: String {
        "\(Int(feePercentage))%"
    }
}
