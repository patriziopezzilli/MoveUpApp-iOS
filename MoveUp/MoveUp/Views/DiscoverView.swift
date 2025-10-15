//
//  DiscoverView.swift
//  MoveUp
//
//  Created by MoveUp Team on 14/10/2025.
//  Scopri - Classifica + Premi uniti in modo elegante
//

import SwiftUI
import Combine

struct DiscoverView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Segmented Control - Minimal
                HStack(spacing: 0) {
                    TabButton(title: "Classifica", icon: "trophy.fill", isSelected: selectedTab == 0) {
                        withAnimation(.spring()) {
                            selectedTab = 0
                        }
                    }
                    
                    TabButton(title: "Premi", icon: "gift.fill", isSelected: selectedTab == 1) {
                        withAnimation(.spring()) {
                            selectedTab = 1
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.moveUpCardBackground)
                
                // Content
                TabView(selection: $selectedTab) {
                    MinimalTopTrainersView()
                        .tag(0)
                    
                    MinimalRewardsView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Scopri")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .moveUpPrimary : .moveUpTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.moveUpPrimary.opacity(0.1) : Color.clear)
            )
        }
    }
}

// MARK: - Minimal Top Trainers
struct MinimalTopTrainersView: View {
    @State private var selectedCity: String = "Milano"
    @State private var rankings: [RankedTrainer] = RankedTrainer.mockData
    
    let availableCities = ["Milano", "Roma", "Torino", "Firenze", "Napoli", "Bologna"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // City Selector - Minimal Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(availableCities, id: \.self) { city in
                            MinimalCityPill(city: city, isSelected: selectedCity == city) {
                                selectedCity = city
                                // Mock: cambia dati in base alla città
                                rankings = RankedTrainer.mockData(for: city)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                
                // Stats Banner
                HStack(spacing: 20) {
                    StatBadge(icon: "person.3.fill", value: "\(rankings.count)", label: "Trainer")
                    StatBadge(icon: "star.fill", value: "4.8", label: "Rating Medio")
                    StatBadge(icon: "calendar.badge.clock", value: "2.4k", label: "Lezioni")
                }
                .padding(.horizontal)
                
                // Top 3 Podium - Minimal
                HStack(alignment: .bottom, spacing: 16) {
                    if rankings.count > 1 {
                        MinimalPodiumCard(trainer: rankings[1], position: 2)
                    }
                    if !rankings.isEmpty {
                        MinimalPodiumCard(trainer: rankings[0], position: 1)
                    }
                    if rankings.count > 2 {
                        MinimalPodiumCard(trainer: rankings[2], position: 3)
                    }
                }
                .padding(.horizontal)
                
                // List resto trainer
                LazyVStack(spacing: 12) {
                    ForEach(Array(rankings.dropFirst(3).enumerated()), id: \.element.id) { index, trainer in
                        MinimalTrainerRow(trainer: trainer, rank: index + 4)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.moveUpBackground)
    }
}

struct MinimalCityPill: View {
    let city: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(city)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .moveUpTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.moveUpPrimary : Color.moveUpCardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.moveUpTextSecondary.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct MinimalPodiumCard: View {
    let trainer: RankedTrainer
    let position: Int
    
    var body: some View {
        VStack(spacing: 8) {
            // Medal
            Text(position == 1 ? "🥇" : position == 2 ? "🥈" : "🥉")
                .font(.system(size: position == 1 ? 48 : 36))
            
            // Avatar flat
            Circle()
                .fill(
                    position == 1 
                        ? Color.moveUpPrimary
                        : position == 2
                        ? Color.blue
                        : Color.orange
                )
                .frame(width: position == 1 ? 70 : 60, height: position == 1 ? 70 : 60)
                .overlay(
                    Text(trainer.initials)
                        .font(.system(size: position == 1 ? 28 : 24, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Text(trainer.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.moveUpTextPrimary)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.moveUpGamification)
                Text(String(format: "%.1f", trainer.rating))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.moveUpTextPrimary)
            }
            
            Text("\(Int(trainer.totalScore)) pt")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.moveUpPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.moveUpPrimary.opacity(0.1))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, position == 1 ? 20 : 12)
        .background(Color.moveUpCardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    position == 1 
                        ? Color.moveUpPrimary.opacity(0.3)
                        : Color.moveUpTextSecondary.opacity(0.1),
                    lineWidth: position == 1 ? 2 : 1
                )
        )
    }
}

struct MinimalTrainerRow: View {
    let trainer: RankedTrainer
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank badge flat
            Text("#\(rank)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.moveUpPrimary)
                )
            
            // Avatar flat
            Circle()
                .fill(Color.moveUpPrimary.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(trainer.initials)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.moveUpPrimary)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(trainer.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.moveUpTextPrimary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.moveUpGamification)
                        Text(String(format: "%.1f", trainer.rating))
                            .font(.system(size: 12))
                            .foregroundColor(.moveUpTextPrimary)
                    }
                    
                    Text("\(trainer.completedLessons) lezioni")
                        .font(.system(size: 12))
                        .foregroundColor(.moveUpTextSecondary)
                }
            }
            
            Spacer()
            
            // Score badge flat
            VStack(spacing: 2) {
                Text("\(Int(trainer.totalScore))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.moveUpPrimary)
                Text("punti")
                    .font(.system(size: 10))
                    .foregroundColor(.moveUpTextSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.moveUpPrimary.opacity(0.1))
            )
        }
        .padding()
        .background(Color.moveUpCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.moveUpTextSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Minimal Rewards
struct MinimalRewardsView: View {
    @StateObject private var viewModel = RewardsViewModel()
    @State private var selectedReward: Reward?
    @State private var showRedeem = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Points Header flat
                VStack(spacing: 12) {
                    Text("\(viewModel.userPoints)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Punti Disponibili")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Level Progress flat
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(viewModel.levelBadge) \(viewModel.levelName)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(viewModel.userPoints)/\(viewModel.nextLevelPoints)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: geo.size.width * CGFloat(viewModel.userPoints) / CGFloat(viewModel.nextLevelPoints), height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(Color.moveUpPrimary)
                .cornerRadius(20)
                .padding(.horizontal)
                
                // Rewards Grid - Clean
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.rewards) { reward in
                        MinimalRewardCard(reward: reward) {
                            selectedReward = reward
                            showRedeem = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 16)
        }
        .background(Color.moveUpBackground)
        .sheet(isPresented: $showRedeem) {
            if let reward = selectedReward {
                RedeemSheet(reward: reward, currentPoints: viewModel.userPoints) {
                    viewModel.redeemReward(reward)
                    showRedeem = false
                }
            }
        }
        .onAppear {
            viewModel.loadRewards()
        }
    }
}

struct MinimalRewardCard: View {
    let reward: Reward
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon con background flat
                ZStack {
                    Circle()
                        .fill(Color.moveUpPrimary.opacity(0.15))
                        .frame(width: 70, height: 70)
                    
                    Text(reward.icon)
                        .font(.system(size: 36))
                }
                
                // Info
                VStack(spacing: 6) {
                    Text(reward.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.moveUpTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.moveUpGamification)
                        Text("\(reward.cost)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.moveUpPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.moveUpCardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.moveUpTextSecondary.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RedeemSheet: View {
    @Environment(\.dismiss) var dismiss
    let reward: Reward
    let currentPoints: Int
    let onRedeem: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text(reward.icon)
                .font(.system(size: 80))
            
            Text(reward.name)
                .font(.system(size: 24, weight: .bold))
            
            Text(reward.description)
                .font(.system(size: 16))
                .foregroundColor(.moveUpTextSecondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Text("Costo:")
                    .foregroundColor(.moveUpTextSecondary)
                Spacer()
                Text("\(reward.cost) punti")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.moveUpPrimary)
            }
            .padding()
            .background(Color.moveUpBackground)
            .cornerRadius(12)
            
            if currentPoints >= reward.cost {
                Button("Riscatta Ora") {
                    onRedeem()
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.moveUpPrimary)
                .cornerRadius(12)
            } else {
                Text("Punti insufficienti")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
            }
            
            Button("Annulla") {
                dismiss()
            }
            .foregroundColor(.moveUpTextSecondary)
        }
        .padding(32)
    }
}

// MARK: - Mock Data Extensions
extension RankedTrainer {
    static let mockData: [RankedTrainer] = [
        RankedTrainer(id: "1", name: "Marco Bianchi", rating: 4.9, completedLessons: 342, totalScore: 895, rankBadge: "👑", specialBadge: "🔥", growthRate: 25.5),
        RankedTrainer(id: "2", name: "Sofia Rossi", rating: 4.8, completedLessons: 298, totalScore: 756, rankBadge: "💎", specialBadge: "⭐", growthRate: 18.2),
        RankedTrainer(id: "3", name: "Luca Ferrari", rating: 4.7, completedLessons: 265, totalScore: 682, rankBadge: "⭐", specialBadge: nil, growthRate: 12.8),
        RankedTrainer(id: "4", name: "Giulia Romano", rating: 4.8, completedLessons: 234, totalScore: 645, rankBadge: "⭐", specialBadge: "🌟", growthRate: 22.1),
        RankedTrainer(id: "5", name: "Andrea Conti", rating: 4.6, completedLessons: 198, totalScore: 542, rankBadge: "✨", specialBadge: nil, growthRate: 8.5),
        RankedTrainer(id: "6", name: "Chiara Marino", rating: 4.7, completedLessons: 187, totalScore: 518, rankBadge: "✨", specialBadge: "🎯", growthRate: 15.3),
        RankedTrainer(id: "7", name: "Matteo Greco", rating: 4.5, completedLessons: 165, totalScore: 462, rankBadge: "🔰", specialBadge: nil, growthRate: 5.2),
        RankedTrainer(id: "8", name: "Valentina Bruno", rating: 4.6, completedLessons: 142, totalScore: 398, rankBadge: "🔰", specialBadge: "💪", growthRate: 19.7),
    ]
    
    static func mockData(for city: String) -> [RankedTrainer] {
        switch city {
        case "Roma":
            return [
                RankedTrainer(id: "r1", name: "Alessandro Ricci", rating: 4.9, completedLessons: 387, totalScore: 921, rankBadge: "👑", specialBadge: "🏆", growthRate: 28.3),
                RankedTrainer(id: "r2", name: "Francesca Colombo", rating: 4.8, completedLessons: 312, totalScore: 788, rankBadge: "💎", specialBadge: "⚡", growthRate: 21.5),
                RankedTrainer(id: "r3", name: "Giovanni Esposito", rating: 4.7, completedLessons: 276, totalScore: 695, rankBadge: "⭐", specialBadge: nil, growthRate: 14.2),
                RankedTrainer(id: "r4", name: "Elena Moretti", rating: 4.8, completedLessons: 245, totalScore: 668, rankBadge: "⭐", specialBadge: "🎪", growthRate: 24.8),
                RankedTrainer(id: "r5", name: "Simone Fontana", rating: 4.6, completedLessons: 209, totalScore: 567, rankBadge: "✨", specialBadge: nil, growthRate: 11.3),
            ]
        case "Torino":
            return [
                RankedTrainer(id: "t1", name: "Laura Barbieri", rating: 4.9, completedLessons: 298, totalScore: 834, rankBadge: "👑", specialBadge: "🌟", growthRate: 31.2),
                RankedTrainer(id: "t2", name: "Davide Villa", rating: 4.7, completedLessons: 267, totalScore: 712, rankBadge: "💎", specialBadge: nil, growthRate: 16.8),
                RankedTrainer(id: "t3", name: "Martina Lombardi", rating: 4.8, completedLessons: 234, totalScore: 654, rankBadge: "⭐", specialBadge: "🔥", growthRate: 23.5),
                RankedTrainer(id: "t4", name: "Roberto Galli", rating: 4.6, completedLessons: 198, totalScore: 558, rankBadge: "✨", specialBadge: nil, growthRate: 9.7),
            ]
        default:
            return mockData
        }
    }
}
