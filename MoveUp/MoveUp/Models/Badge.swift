//
//  Badge.swift
//  MoveUp
//
//  Created by iOS Developer on 30/12/24.
//

import Foundation

struct Badge: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
    let isUnlocked: Bool
    let unlockedDate: Date?
    let category: BadgeCategory
    let rarity: BadgeRarity
    let pointsRequired: Int?
}

enum BadgeCategory: String, CaseIterable, Codable {
    case achievement = "achievement"
    case streak = "streak" 
    case social = "social"
    case milestone = "milestone"
    
    var displayName: String {
        switch self {
        case .achievement: return "Traguardi"
        case .streak: return "Streak"
        case .social: return "Social"
        case .milestone: return "Milestone"
        }
    }
    
    var icon: String {
        switch self {
        case .achievement: return "trophy.fill"
        case .streak: return "flame.fill"
        case .social: return "person.3.fill"
        case .milestone: return "star.fill"
        }
    }
}

enum BadgeRarity: String, CaseIterable, Codable {
    case common = "common"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    var color: String {
        switch self {
        case .common: return "gray"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "orange"
        }
    }
}

extension Badge {
    static let sampleBadges = [
        Badge(
            name: "Prima Lezione",
            description: "Completa la tua prima lezione",
            imageName: "star.fill",
            isUnlocked: true,
            unlockedDate: Date().addingTimeInterval(-86400 * 7),
            category: .milestone,
            rarity: .common,
            pointsRequired: 0
        ),
        Badge(
            name: "Streak 7 giorni",
            description: "Mantieni una streak di 7 giorni consecutivi",
            imageName: "flame.fill",
            isUnlocked: true,
            unlockedDate: Date().addingTimeInterval(-86400 * 3),
            category: .streak,
            rarity: .rare,
            pointsRequired: 350
        ),
        Badge(
            name: "Campione Tennis",
            description: "Completa 10 lezioni di tennis",
            imageName: "tennis.racket",
            isUnlocked: false,
            unlockedDate: nil,
            category: .achievement,
            rarity: .epic,
            pointsRequired: 1000
        ),
        Badge(
            name: "Social Star", 
            description: "Invita 5 amici nell'app",
            imageName: "person.3.fill",
            isUnlocked: false,
            unlockedDate: nil,
            category: .social,
            rarity: .rare,
            pointsRequired: 500
        ),
        Badge(
            name: "Maestro MoveUp",
            description: "Raggiungi il livello 10",
            imageName: "crown.fill",
            isUnlocked: false,
            unlockedDate: nil,
            category: .milestone,
            rarity: .legendary,
            pointsRequired: 5000
        )
    ]
}