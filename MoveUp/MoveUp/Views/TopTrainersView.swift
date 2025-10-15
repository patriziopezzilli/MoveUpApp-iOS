//
//  TopTrainersView.swift
//  MoveUp
//
//  Created by MoveUp Team on 14/10/2025.
//  Leaderboard trainer con city background - grafica FIGA
//

import SwiftUI
import Combine

struct TopTrainersView: View {
    @StateObject private var viewModel = TopTrainersViewModel()
    @State private var selectedCity: String = "Milano"
    @State private var selectedSport: String? = nil
    
    let cities = [
        "Milano": "milan_skyline",
        "Roma": "rome_colosseum", 
        "Firenze": "florence_duomo",
        "Napoli": "naples_view",
        "Venezia": "venice_canal"
    ]
    
    var body: some View {
        ZStack {
            // City background image con gradient overlay
            if let imageName = cities[selectedCity] {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .blur(radius: 8)
                    .overlay(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 0) {
                // Header con city picker
                VStack(spacing: 16) {
                    Text("Top Trainer")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    // City selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(cities.keys.sorted()), id: \.self) { city in
                                CityPill(
                                    city: city,
                                    isSelected: selectedCity == city,
                                    onTap: {
                                        withAnimation(.spring()) {
                                            selectedCity = city
                                            viewModel.loadRankings(city: city, sport: selectedSport)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Sport filter
                    if !viewModel.availableSports.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                TopTrainersSportChip(
                                    sport: "Tutti",
                                    isSelected: selectedSport == nil,
                                    onTap: {
                                        selectedSport = nil
                                        viewModel.loadRankings(city: selectedCity, sport: nil)
                                    }
                                )
                                
                                ForEach(viewModel.availableSports, id: \.self) { sport in
                                    TopTrainersSportChip(
                                        sport: sport,
                                        isSelected: selectedSport == sport,
                                        onTap: {
                                            selectedSport = sport
                                            viewModel.loadRankings(city: selectedCity, sport: sport)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Stats banner
                    HStack(spacing: 30) {
                        StatBadge(icon: "person.3.fill", value: "\(viewModel.rankings.count)", label: "Trainer")
                        StatBadge(icon: "star.fill", value: String(format: "%.1f", viewModel.averageRating), label: "Rating medio")
                        StatBadge(icon: "calendar.badge.checkmark", value: "\(viewModel.totalLessons)", label: "Lezioni")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
                
                // Podium (Top 3)
                if viewModel.rankings.count >= 3 {
                    PodiumView(
                        first: viewModel.rankings[0],
                        second: viewModel.rankings[1],
                        third: viewModel.rankings[2]
                    )
                    .padding(.vertical)
                }
                
                // Leaderboard list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.rankings.enumerated()), id: \.element.id) { index, trainer in
                            if index >= 3 { // Skip top 3 (already in podium)
                                TrainerRankCard(
                                    trainer: trainer,
                                    rank: index + 1
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            viewModel.loadRankings(city: selectedCity, sport: selectedSport)
        }
    }
}

// MARK: - City Pill
struct CityPill: View {
    let city: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(city)
                .font(.headline)
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    isSelected 
                        ? Color.white
                        : Color.white.opacity(0.2)
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - Sport Chip
struct TopTrainersSportChip: View {
    let sport: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(sport)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.moveUpPrimary : Color.white.opacity(0.15))
                .cornerRadius(15)
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.moveUpPrimary)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.moveUpTextPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.moveUpTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.moveUpCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.moveUpTextSecondary.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Podium View
struct PodiumView: View {
    let first: RankedTrainer
    let second: RankedTrainer
    let third: RankedTrainer
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // 2nd place
            PodiumCard(trainer: second, place: 2, height: 140)
            
            // 1st place (higher)
            PodiumCard(trainer: first, place: 1, height: 180)
            
            // 3rd place
            PodiumCard(trainer: third, place: 3, height: 120)
        }
        .padding(.horizontal, 20)
    }
}

struct PodiumCard: View {
    let trainer: RankedTrainer
    let place: Int
    let height: CGFloat
    
    var medalEmoji: String {
        switch place {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    var medalColor: Color {
        switch place {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Medal
            Text(medalEmoji)
                .font(.system(size: 40))
            
            // Avatar
            Circle()
                .fill(medalColor.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(trainer.initials)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Name
            Text(trainer.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            // Score
            VStack(spacing: 2) {
                Text("\(Int(trainer.totalScore))")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Text("punti")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Badge
            Text(trainer.rankBadge)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(medalColor.opacity(0.5))
                .cornerRadius(8)
        }
        .frame(width: 110, height: height)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(medalColor, lineWidth: 2)
                )
        )
    }
}

// MARK: - Trainer Rank Card
struct TrainerRankCard: View {
    let trainer: RankedTrainer
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank number
            Text("#\(rank)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 50)
            
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(trainer.initials)
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trainer.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let badge = trainer.specialBadge {
                        Text(badge)
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", trainer.rating))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("\(trainer.completedLessons) lezioni")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Score
            VStack(spacing: 2) {
                Text("\(Int(trainer.totalScore))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                Text(trainer.rankBadge)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - View Model
class TopTrainersViewModel: ObservableObject {
    @Published var rankings: [RankedTrainer] = []
    @Published var availableSports = ["Tennis", "Padel", "Golf", "Fitness"]
    @Published var averageRating: Double = 0.0
    @Published var totalLessons: Int = 0
    
    func loadRankings(city: String, sport: String?) {
        var urlString = "http://localhost:8080/api/rankings/city/\(city)?limit=20"
        if let sport = sport {
            urlString += "&sport=\(sport)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(RankingResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.rankings = result.rankings
                    self?.calculateStats()
                }
            } catch {
                print("Decode error: \(error)")
            }
        }.resume()
    }
    
    private func calculateStats() {
        let ratings = rankings.map { $0.rating }
        averageRating = ratings.isEmpty ? 0 : ratings.reduce(0, +) / Double(ratings.count)
        totalLessons = rankings.reduce(0) { $0 + $1.completedLessons }
    }
}

// MARK: - Data Models
struct RankedTrainer: Identifiable, Codable {
    let id: String
    let name: String
    let rating: Double
    let completedLessons: Int
    let totalScore: Double
    let rankBadge: String
    let specialBadge: String?
    let growthRate: Double?
    
    var initials: String {
        name.split(separator: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }
}

struct RankingResponse: Codable {
    let success: Bool
    let city: String
    let sport: String
    let rankings: [RankedTrainer]
}

// MARK: - Preview
struct TopTrainersView_Previews: PreviewProvider {
    static var previews: some View {
        TopTrainersView()
    }
}
