//
//  Wallet.swift
//  MoveUp
//
//  Created on 14/10/2024.
//

import Foundation

struct Wallet: Codable, Identifiable {
    let id: String
    let userId: String
    var balance: Double
    var currency: String = "EUR"
    
    // Bank account setup
    var bankAccountSetup: Bool = false
    var maskedIban: String?  // e.g., "IT60 •••• •••• •••• 3456"
    var accountHolderName: String?
    
    // Stripe Connect
    var stripeConnectedAccountId: String?
    
    // Stats
    var totalEarnings: Double = 0.0
    var totalLessons: Int = 0
    var totalWithdrawn: Double = 0.0
    
    var averageLessonPrice: Double {
        totalLessons > 0 ? totalEarnings / Double(totalLessons) : 0
    }
    
    var availableBalance: Double {
        balance
    }
    
    // iOS Wallet Pass
    var passSerialNumber: String?
    var passUpdateToken: String?
    var passAddedToWallet: Bool = false
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    
    // Computed properties
    var formattedBalance: String {
        String(format: "€%.2f", balance)
    }
    
    var formattedTotalEarnings: String {
        String(format: "€%.2f", totalEarnings)
    }
    
    var ibanLastFourDigits: String? {
        guard let iban = maskedIban else { return nil }
        let digits = iban.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "•", with: "")
        return String(digits.suffix(4))
    }
}

// MARK: - Wallet Setup DTO
struct WalletSetupRequest: Codable {
    let iban: String
    let accountHolderName: String
    let country: String = "IT"
}

// MARK: - Wallet Response
struct WalletResponse: Codable {
    let wallet: Wallet
    let recentTransactions: [Transaction]?
}
