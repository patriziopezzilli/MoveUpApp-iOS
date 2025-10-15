import Foundation

// MARK: - Review Model
struct Review: Identifiable, Codable {
    let id: String
    var bookingId: String
    var reviewerId: String // User who wrote the review
    var revieweeId: String // User being reviewed
    var rating: Int // 1-5 stars
    var comment: String?
    var isFromInstructor: Bool // true if instructor reviews user, false if user reviews instructor
    var createdAt: Date
    var updatedAt: Date
    
    var ratingStars: String {
        String(repeating: "★", count: rating) + String(repeating: "☆", count: 5 - rating)
    }
}

// MARK: - Notification Model
struct AppNotification: Identifiable, Codable {
    let id: String
    var userId: String
    var title: String
    var message: String
    var type: NotificationType
    var isRead: Bool = false
    var actionURL: String?
    var createdAt: Date
}

enum NotificationType: String, CaseIterable, Codable {
    case booking = "booking"
    case payment = "payment"
    case review = "review"
    case promotion = "promotion"
    case system = "system"
    
    var iconName: String {
        switch self {
        case .booking: return "calendar"
        case .payment: return "creditcard"
        case .review: return "star"
        case .promotion: return "gift"
        case .system: return "bell"
        }
    }
    
    var color: String {
        switch self {
        case .booking: return "moveUpSecondary"
        case .payment: return "moveUpAccent2"
        case .review: return "moveUpGamification"
        case .promotion: return "moveUpAccent1"
        case .system: return "moveUpPrimary"
        }
    }
}

// MARK: - Analytics Model
struct InstructorAnalytics: Codable {
    var totalLessons: Int = 0
    var totalEarnings: Double = 0.0
    var averageRating: Double = 0.0
    var totalReviews: Int = 0
    var completionRate: Double = 0.0 // Percentage of lessons completed vs cancelled
    var responseTime: TimeInterval = 0 // Average response time to bookings
    var monthlyStats: [MonthlyStats] = []
}

struct MonthlyStats: Codable {
    var month: Int
    var year: Int
    var lessonsCount: Int
    var earnings: Double
    var newStudents: Int
}

// MARK: - Filter Models
struct LessonFilter {
    var sports: [Sport] = []
    var priceRange: ClosedRange<Double> = 0...200
    var maxDistance: Double = 50 // km
    var skillLevels: [SkillLevel] = []
    var availableToday: Bool = false
    var availableThisWeek: Bool = false
    var sortBy: LessonSortOption = .distance
}

enum LessonSortOption: String, CaseIterable {
    case distance = "distance"
    case price = "price"
    case rating = "rating"
    case newest = "newest"
    
    var displayName: String {
        switch self {
        case .distance: return "Distanza"
        case .price: return "Prezzo"
        case .rating: return "Valutazione"
        case .newest: return "Più recenti"
        }
    }
}