//
//  RewardsView.swift
//  MoveUp
//
//  Created by MoveUp Team on 14/10/2025.
//  Gamification rewards catalog - design FIGO
//

import SwiftUI
import Combine

struct RewardsView: View {
    @StateObject private var viewModel = RewardsViewModel()
    @State private var selectedReward: Reward?
    @State private var showRedeemConfirm = false
    
    var body: some View {
        ZStack {
            // Background flat
            Color.moveUpBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header con punti
                PointsHeaderCard(
                    points: viewModel.userPoints,
                    level: viewModel.userLevel,
                    levelName: viewModel.levelName,
                    levelBadge: viewModel.levelBadge,
                    nextLevelPoints: viewModel.nextLevelPoints
                )
                .padding()
                
                // Rewards catalog
                ScrollView {
                    VStack(spacing: 20) {
                        // Section header
                        HStack {
                            Text("🎁 Premi Disponibili")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Rewards grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(viewModel.rewards) { reward in
                                RewardCard(
                                    reward: reward,
                                    userPoints: viewModel.userPoints,
                                    onTap: {
                                        selectedReward = reward
                                        showRedeemConfirm = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // How to earn section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("💡 Come Guadagnare Punti")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                EarnPointsRow(icon: "checkmark.circle.fill", text: "Completa una lezione", points: 20, color: .green)
                                EarnPointsRow(icon: "star.fill", text: "Scrivi una recensione", points: 10, color: .orange)
                                EarnPointsRow(icon: "person.badge.plus", text: "Invita un amico", points: 100, color: .purple)
                                EarnPointsRow(icon: "flame.fill", text: "Streak 3 lezioni", points: 30, color: .red)
                                EarnPointsRow(icon: "gift.fill", text: "Bonus prima lezione", points: 50, color: .blue)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showRedeemConfirm) {
            if let reward = selectedReward {
                RedeemConfirmSheet(
                    reward: reward,
                    userPoints: viewModel.userPoints,
                    onConfirm: {
                        viewModel.redeemReward(reward)
                        showRedeemConfirm = false
                    },
                    onCancel: {
                        showRedeemConfirm = false
                    }
                )
            }
        }
        .alert("Errore", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "Errore sconosciuto")
        }
        .alert("Successo!", isPresented: $viewModel.showSuccess) {
            Button("Fantastico!") { }
        } message: {
            Text(viewModel.successMessage ?? "Reward riscattato!")
        }
        .onAppear {
            viewModel.loadRewards()
        }
    }
}

// MARK: - Points Header Card
struct PointsHeaderCard: View {
    let points: Int
    let level: Int
    let levelName: String
    let levelBadge: String
    let nextLevelPoints: Int
    
    var progressToNextLevel: Double {
        let currentLevelMin = getLevelMinPoints(level)
        let nextLevelMin = getLevelMinPoints(level + 1)
        let progress = Double(points - currentLevelMin) / Double(nextLevelMin - currentLevelMin)
        return min(max(progress, 0), 1)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Points display
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("I Tuoi Punti")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(points)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Level badge
                VStack(spacing: 4) {
                    Text(levelBadge)
                        .font(.system(size: 50))
                    
                    Text("Lv. \(level)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            // Progress to next level
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(levelName)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(nextLevelPoints - points) punti al prossimo livello")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.3))
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * progressToNextLevel)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding(24)
        .background(Color.moveUpPrimary)
        .cornerRadius(20)
    }
    
    private func getLevelMinPoints(_ level: Int) -> Int {
        switch level {
        case 1: return 0
        case 2: return 100
        case 3: return 300
        case 4: return 600
        case 5: return 1000
        default: return 0
        }
    }
}

// MARK: - Reward Card
struct RewardCard: View {
    let reward: Reward
    let userPoints: Int
    let onTap: () -> Void
    
    var canAfford: Bool {
        userPoints >= reward.cost
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Text(reward.icon)
                .font(.system(size: 50))
                .frame(maxWidth: .infinity)
            
            // Name
            Text(reward.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            // Description
            Text(reward.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Divider()
            
            // Cost + CTA
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(reward.cost)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Button(action: onTap) {
                    Text(canAfford ? "Riscatta" : "Blocca")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(canAfford ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(canAfford ? .white : .gray)
                        .cornerRadius(8)
                }
                .disabled(!canAfford)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        
        .opacity(canAfford ? 1.0 : 0.6)
    }
}

// MARK: - Earn Points Row
struct EarnPointsRow: View {
    let icon: String
    let text: String
    let points: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("+\(points)")
                    .font(.headline)
                    .foregroundColor(color)
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Redeem Confirm Sheet
struct RedeemConfirmSheet: View {
    let reward: Reward
    let userPoints: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Text(reward.icon)
                .font(.system(size: 80))
            
            // Title
            Text("Conferma Riscatto")
                .font(.title2)
                .fontWeight(.bold)
            
            // Reward info
            VStack(spacing: 8) {
                Text(reward.name)
                    .font(.headline)
                
                Text(reward.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Cost
            HStack {
                Text("Costo:")
                Spacer()
                HStack(spacing: 4) {
                    Text("\(reward.cost)")
                        .fontWeight(.bold)
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Remaining points
            HStack {
                Text("Punti rimanenti:")
                Spacer()
                Text("\(userPoints - reward.cost)")
                    .fontWeight(.bold)
                    .foregroundColor(userPoints - reward.cost >= 0 ? .green : .red)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            // Buttons
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Text("Annulla")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                
                Button(action: onConfirm) {
                    Text("Conferma")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.moveUpPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(30)
    }
}

// MARK: - View Model
class RewardsViewModel: ObservableObject {
    @Published var rewards: [Reward] = []
    @Published var userPoints = 150 // TODO: get from API
    @Published var userLevel = 2
    @Published var levelName = "Appassionato"
    @Published var levelBadge = "⭐"
    @Published var nextLevelPoints = 300
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    init() {
        // Mock data per demo
        self.rewards = Reward.mockData
        self.userPoints = 650
        self.levelName = "Campione Locale"
        self.levelBadge = "💎"
        self.nextLevelPoints = 850
    }
    
    func loadRewards() {
        // Mock data già caricato in init per demo
        return
        
        /* API call per produzione:
        let urlString = "http://localhost:8080/api/points/rewards"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(RewardsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.rewards = result.rewards
                }
            } catch {
                print("Decode error: \(error)")
            }
        }.resume()
        */
    }
    
    func redeemReward(_ reward: Reward) {
        let urlString = "http://localhost:8080/api/points/redeem"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "userId": "user123", // TODO: get from auth
            "rewardId": reward.id
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(RedeemResponse.self, from: data)
                DispatchQueue.main.async {
                    if result.success {
                        self?.userPoints = result.result.remainingPoints
                        self?.successMessage = result.message
                        self?.showSuccess = true
                    } else {
                        self?.errorMessage = result.error
                        self?.showError = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Errore nel riscatto"
                    self?.showError = true
                }
            }
        }.resume()
    }
}

// MARK: - Data Models
struct Reward: Identifiable, Codable {
    let id: String
    let name: String
    let cost: Int
    let description: String
    let type: String
    
    var icon: String {
        switch type {
        case "tshirt": return "🎽"
        case "free_lesson": return "🎟️"
        case "discount_20": return "💳"
        case "discount_30": return "💎"
        case "discount_50": return "🏆"
        case "bag": return "🎒"
        case "kit": return "👕"
        case "vip_lesson": return "🏆"
        case "premium": return "👑"
        case "bundle": return "📦"
        case "maglietta_moveup": return "👕"
        case "decathlon_voucher": return "🎁"
        case "nike_voucher": return "✨"
        default: return "🎁"
        }
    }
    
    static let mockData: [Reward] = [
        Reward(id: "1", name: "T-Shirt MoveUp", cost: 150, description: "T-shirt ufficiale MoveUp in cotone premium", type: "tshirt"),
        Reward(id: "2", name: "Lezione Gratuita", cost: 200, description: "Una lezione gratuita con un trainer a scelta", type: "free_lesson"),
        Reward(id: "3", name: "Sconto 20%", cost: 100, description: "Sconto 20% sulla prossima lezione", type: "discount_20"),
        Reward(id: "4", name: "Borsa Sportiva", cost: 300, description: "Borsa sportiva MoveUp con tasche multiple", type: "bag"),
        Reward(id: "5", name: "Kit Premium", cost: 500, description: "Kit completo: T-shirt + Borsa + Bottiglia", type: "kit"),
        Reward(id: "6", name: "Sconto 30%", cost: 250, description: "Sconto 30% valido per 7 giorni", type: "discount_30"),
        Reward(id: "7", name: "Lezione VIP", cost: 400, description: "Sessione esclusiva con trainer top rated", type: "vip_lesson"),
        Reward(id: "8", name: "Premium Pack", cost: 600, description: "3 lezioni + Kit completo + Priorità booking", type: "premium"),
        Reward(id: "9", name: "Sconto 50%", cost: 450, description: "Mega sconto 50% sulla prossima lezione", type: "discount_50"),
        Reward(id: "10", name: "Bundle Sport", cost: 350, description: "5 lezioni al prezzo di 3", type: "bundle"),
        Reward(id: "11", name: "Maglietta MoveUp", cost: 180, description: "Maglietta tecnica MoveUp con logo ricamato", type: "maglietta_moveup"),
        Reward(id: "12", name: "Buono Decathlon 20€", cost: 220, description: "Buono acquisto da 20€ valido su Decathlon.it", type: "decathlon_voucher"),
        Reward(id: "13", name: "Buono Nike 50€", cost: 550, description: "Buono acquisto da 50€ per il Nike Store", type: "nike_voucher"),
    ]
}

struct RewardsResponse: Codable {
    let success: Bool
    let rewards: [Reward]
    let count: Int
}

struct RedeemResponse: Codable {
    let success: Bool
    let result: RedemptionResult
    let message: String
    let error: String?
}

struct RedemptionResult: Codable {
    let remainingPoints: Int
}

// MARK: - Preview
struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}
