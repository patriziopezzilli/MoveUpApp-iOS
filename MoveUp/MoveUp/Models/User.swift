import Foundation

// MARK: - User Types
enum UserType: String, CaseIterable, Codable {
    case user = "user"
    case instructor = "instructor"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .user: return "Utente"
        case .instructor: return "Istruttore"
        case .admin: return "Admin"
        }
    }
}

// MARK: - User Model
struct User: Identifiable, Codable {
    let id = UUID()
    let name: String
    let email: String
    let profileImageName: String
    let points: Int
    let level: Int
    let badges: [Badge]
    let completedLessons: [CompletedLesson]
    let location: String
    let phoneNumber: String
    let dateOfBirth: String
    let preferredSports: [Sport]
}



// MARK: - Sample Data
extension Instructor {
    static let sampleInstructor = Instructor(
        id: "instructor1",
        userId: "user2",
        bio: "Istruttore di tennis con 10 anni di esperienza. Specializzato nell'insegnamento ai principianti e nel perfezionamento della tecnica. Ho allenato giocatori di tutti i livelli, dal principiante al competitivo.",
        specializations: [
            Sport(id: "tennis", name: "Tennis", category: .racquet, iconName: "tennis.racket", isPopular: true),
            Sport(id: "padel", name: "Padel", category: .racquet, iconName: "tennis.racket", isPopular: true)
        ],
        certifications: [
            Certification(
                id: "cert1",
                name: "Maestro Nazionale FIT",
                issuingOrganization: "Federazione Italiana Tennis",
                issueDate: Date().addingTimeInterval(-86400 * 365 * 5),
                expirationDate: nil,
                certificateURL: nil,
                isVerified: true
            ),
            Certification(
                id: "cert2", 
                name: "Istruttore Padel FITP",
                issuingOrganization: "Federazione Italiana Tennis e Padel",
                issueDate: Date().addingTimeInterval(-86400 * 365 * 2),
                expirationDate: nil,
                certificateURL: nil,
                isVerified: true
            )
        ],
        hourlyRate: 45.0,
        availability: [],
        location: LocationData(
            latitude: 45.4642,
            longitude: 9.1900,
            address: "Via Brera 15",
            city: "Milano",
            region: "Lombardia",
            country: "Italia"
        ),
        isApproved: true,
        rating: 4.8,
        totalLessons: 150,
        totalEarnings: 6750.0,
        profileCompletion: 0.95,
        createdAt: Date().addingTimeInterval(-86400 * 365),
        updatedAt: Date()
    )
}

extension User {
    static let sampleUser = User(
        name: "Marco Rossi",
        email: "marco.rossi@gmail.com",
        profileImageName: "profile_sample",
        points: 2450,
        level: 5,
        badges: Badge.sampleBadges,
        completedLessons: CompletedLesson.sampleLessons,
        location: "Milano, Italia",
        phoneNumber: "+39 334 123 4567",
        dateOfBirth: "15/03/1990",
        preferredSports: Sport.sampleSports
    )
}

extension Sport {
    static let sampleSports = [
        Sport(id: "1", name: "Tennis", category: .racquet, iconName: "tennis"),
        Sport(id: "2", name: "Calcio", category: .team, iconName: "soccer"), 
        Sport(id: "3", name: "Nuoto", category: .water, iconName: "swimming"),
        Sport(id: "4", name: "Fitness", category: .fitness, iconName: "dumbbell")
    ]
}

// MARK: - Instructor Model
struct Instructor: Identifiable, Codable {
    let id: String
    var userId: String // Reference to User
    var bio: String
    var specializations: [Sport]
    var certifications: [Certification]
    var hourlyRate: Double
    var availability: [Availability]
    var location: LocationData
    var isApproved: Bool = false
    var rating: Double = 0.0
    var totalLessons: Int = 0
    var totalEarnings: Double = 0.0
    var profileCompletion: Double = 0.0
    var createdAt: Date
    var updatedAt: Date
}

// MARK: - Sport Model
struct Sport: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var category: SportCategory
    var iconName: String
    var isPopular: Bool = false
}

enum SportCategory: String, CaseIterable, Codable {
    case racquet = "racquet"
    case team = "team"
    case water = "water"
    case fitness = "fitness"
    case wellness = "wellness"
    case running = "running"
    case combat = "combat"
    case winter = "winter"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .racquet: return "Racchette"
        case .team: return "Sport di squadra"
        case .water: return "Sport acquatici"
        case .fitness: return "Fitness"
        case .wellness: return "Benessere"
        case .running: return "Corsa"
        case .combat: return "Arti marziali"
        case .winter: return "Sport invernali"
        case .other: return "Altri"
        }
    }
}

// MARK: - Skill Level
enum SkillLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case professional = "professional"
    
    var displayName: String {
        switch self {
        case .beginner: return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced: return "Avanzato"
        case .professional: return "Professionale"
        }
    }
}

// MARK: - Location Data
struct LocationData: Codable {
    var latitude: Double
    var longitude: Double
    var address: String
    var city: String
    var region: String
    var country: String
    
    var coordinate: (latitude: Double, longitude: Double) {
        (latitude, longitude)
    }
}

// MARK: - Certification
struct Certification: Identifiable, Codable {
    let id: String
    var name: String
    var issuingOrganization: String
    var issueDate: Date
    var expirationDate: Date?
    var certificateURL: String?
    var isVerified: Bool = false
}

// MARK: - Availability
struct Availability: Identifiable, Codable {
    let id: String
    var dayOfWeek: WeekDay
    var startTime: Date
    var endTime: Date
    var isAvailable: Bool = true
}

enum WeekDay: Int, CaseIterable, Codable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var displayName: String {
        switch self {
        case .monday: return "Lunedì"
        case .tuesday: return "Martedì"
        case .wednesday: return "Mercoledì"
        case .thursday: return "Giovedì"
        case .friday: return "Venerdì"
        case .saturday: return "Sabato"
        case .sunday: return "Domenica"
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "Lun"
        case .tuesday: return "Mar"
        case .wednesday: return "Mer"
        case .thursday: return "Gio"
        case .friday: return "Ven"
        case .saturday: return "Sab"
        case .sunday: return "Dom"
        }
    }
}