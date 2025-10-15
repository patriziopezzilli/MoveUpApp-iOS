//
//  FeeBreakdownView.swift
//  MoveUp
//
//  Created on 14/10/2024.
//

import SwiftUI

struct FeeBreakdownView: View {
    let grossAmount: Double      // Prezzo pagato dal customer
    let platformFee: Double      // Fee piattaforma
    
    var netAmount: Double {
        grossAmount - platformFee
    }
    
    var feePercentage: Double {
        grossAmount > 0 ? (platformFee / grossAmount) * 100 : 0
    }
    
    var trainerPercentage: Double {
        100 - feePercentage
    }
    
    @State private var animateFlow = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Dettaglio Pagamento")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Flow visualization
            HStack(spacing: 0) {
                // Customer pays
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "eurosign.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Pagato")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("€\(grossAmount, specifier: "%.2f")")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                
                // Arrow with animation
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .offset(x: animateFlow ? 5 : -5)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: animateFlow
                    )
                
                // Trainer receives
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.green)
                    }
                    
                    Text("Al Trainer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("€\(netAmount, specifier: "%.2f")")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                
                // Arrow with animation
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .offset(x: animateFlow ? 5 : -5)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true)
                            .delay(0.3),
                        value: animateFlow
                    )
                
                // Platform fee
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: platformFee == 0 ? "gift.fill" : "building.2.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.orange)
                    }
                    
                    Text(platformFee == 0 ? "Gratis!" : "Fee MoveUp")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("€\(platformFee, specifier: "%.2f")")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            
            // Progress bar visualization
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray5))
                            .frame(height: 40)
                        
                        HStack(spacing: 0) {
                            // Trainer portion (green)
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.8), Color.green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * (netAmount / grossAmount))
                                .overlay(
                                    Text("\(Int(trainerPercentage))%")
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.white)
                                        .opacity(trainerPercentage > 15 ? 1 : 0)
                                )
                            
                            // Fee portion (orange)
                            if platformFee > 0 {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.8), Color.orange],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * (platformFee / grossAmount))
                                    .overlay(
                                        Text("\(Int(feePercentage))%")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.white)
                                            .opacity(feePercentage > 10 ? 1 : 0)
                                    )
                            }
                        }
                    }
                }
                .frame(height: 40)
                
                // Legend
                HStack(spacing: 20) {
                    Label {
                        Text("Trainer: €\(netAmount, specifier: "%.2f") (\(Int(trainerPercentage))%)")
                            .font(.caption)
                    } icon: {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                    }
                    
                    if platformFee > 0 {
                        Label {
                            Text("Fee: €\(platformFee, specifier: "%.2f") (\(Int(feePercentage))%)")
                                .font(.caption)
                        } icon: {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 10, height: 10)
                        }
                    } else {
                        Label {
                            Text("Nessuna fee! 🎉")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "gift.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                }
                .foregroundColor(.secondary)
            }
            
            // Info card (if zero fee)
            if platformFee == 0 {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Periodo Promozionale!")
                            .font(.subheadline)
                            .bold()
                        
                        Text("Il trainer riceve l'intero importo. Nessuna commissione applicata.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding()
        .onAppear {
            animateFlow = true
        }
    }
}

// MARK: - Compact Version (for cards)
struct FeeBreakdownCompactView: View {
    let grossAmount: Double
    let platformFee: Double
    
    var netAmount: Double {
        grossAmount - platformFee
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Prezzo lezione")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("€\(grossAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .bold()
            }
            
            if platformFee > 0 {
                HStack {
                    Text("Fee piattaforma")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("-€\(platformFee, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
            
            HStack {
                Text("Guadagno trainer")
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Text("€\(netAmount, specifier: "%.2f")")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Preview
#Preview("Fee 0%") {
    FeeBreakdownView(grossAmount: 50.0, platformFee: 0.0)
}

#Preview("Fee 10%") {
    FeeBreakdownView(grossAmount: 50.0, platformFee: 5.0)
}

#Preview("Fee 15%") {
    FeeBreakdownView(grossAmount: 50.0, platformFee: 7.5)
}

#Preview("Compact") {
    FeeBreakdownCompactView(grossAmount: 50.0, platformFee: 5.0)
        .padding()
}
