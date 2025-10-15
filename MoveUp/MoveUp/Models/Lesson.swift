import Foundation

// MARK: - Lesson Model
struct Lesson: Identifiable, Codable {
    let id: String
    var instructorId: String
    var sport: Sport
    var title: String
    var description: String
    var price: Double
    var duration: TimeInterval // in seconds
    var location: LocationData
    var maxParticipants: Int = 1 // MVP focuses on individual lessons
    var skillLevel: SkillLevel
    var equipment: [String] = [] // Required equipment
    var isActive: Bool = true
    var createdAt: Date
    var updatedAt: Date
    
    // Computed properties
    var durationInMinutes: Int {
        Int(duration / 60)
    }
    
    var priceFormatted: String {
        String(format: "€%.2f", price)
    }
    
    var durationFormatted: String {
        if durationInMinutes < 60 {
            return "\(durationInMinutes)min"
        } else {
            let hours = durationInMinutes / 60
            let minutes = durationInMinutes % 60
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)min"
            }
        }
    }
}

// MARK: - Booking Model
struct Booking: Identifiable, Codable {
    let id: String
    var lessonId: String
    var instructorId: String
    var userId: String
    var scheduledDate: Date
    var status: BookingStatus
    var paymentStatus: PaymentStatus
    var totalAmount: Double
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Display info
    var sport: String?
    var instructorName: String?
    var price: Double?
    
    // Payment info
    var paymentId: String?
    var refundId: String?
    
    // Wallet payment fields
    var paymentIntentId: String?
    var stripeTransferId: String?
    var validatedAt: Date?
    
    // Computed properties for display
    var statusDisplayName: String {
        status.displayName
    }
    
    var statusColor: String {
        status.color
    }
    
    var formattedAmount: String {
        String(format: "€%.2f", totalAmount)
    }
    
    // Helper property for UI
    var lessonDate: Date {
        scheduledDate
    }
    
    var bookingDate: Date {
        createdAt
    }
}

enum BookingStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
    case refunded = "refunded"
    
    var displayName: String {
        switch self {
        case .pending: return "In attesa"
        case .confirmed: return "Confermata"
        case .completed: return "Completata"
        case .cancelled: return "Cancellata"
        case .noShow: return "Assente"
        case .refunded: return "Rimborsata"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "moveUpAccent1"
        case .confirmed: return "moveUpSecondary"
        case .completed: return "moveUpSuccess"
        case .cancelled, .noShow, .refunded: return "moveUpError"
        }
    }
}

enum PaymentStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case authorized = "authorized"
    case captured = "captured"
    case refunded = "refunded"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .pending: return "In elaborazione"
        case .authorized: return "Autorizzato"
        case .captured: return "Completato"
        case .refunded: return "Rimborsato"
        case .failed: return "Fallito"
        }
    }
}

// MARK: - QR Code Support
extension Booking {
    /// QR code data for lesson validation
    var qrCodeData: String {
        "MOVEUP:BOOKING:\(id):TRAINER:\(instructorId)"
    }
    
    /// Can validate the lesson
    var canValidate: Bool {
        status == .confirmed && paymentStatus == .authorized && validatedAt == nil
    }
    
    /// Validate a scanned QR code
    static func isValidQR(_ scannedData: String) -> Bool {
        scannedData.hasPrefix("MOVEUP:BOOKING:")
    }
    
    /// Parse QR code to extract booking ID
    static func parseQRCode(_ qrData: String) -> (bookingId: String, trainerId: String)? {
        let components = qrData.components(separatedBy: ":")
        guard components.count == 5,
              components[0] == "MOVEUP",
              components[1] == "BOOKING",
              components[3] == "TRAINER" else {
            return nil
        }
        return (bookingId: components[2], trainerId: components[4])
    }
}

// MARK: - Sample Booking Data
extension Booking {
    static let sampleBookings = [
        Booking(
            id: "booking1",
            lessonId: "lesson1",
            instructorId: "instructor1",
            userId: "user1",
            scheduledDate: Date().addingTimeInterval(86400 * 3), // 3 days from now
            status: .confirmed,
            paymentStatus: .captured,
            totalAmount: 45.0,
            notes: nil,
            createdAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 2),
            paymentId: "payment1",
            refundId: nil
        ),
        Booking(
            id: "booking2",
            lessonId: "lesson2",
            instructorId: "instructor2", 
            userId: "user1",
            scheduledDate: Date().addingTimeInterval(-86400 * 1), // 1 day ago
            status: .completed,
            paymentStatus: .captured,
            totalAmount: 60.0,
            notes: "Ottima lezione!",
            createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 1),
            paymentId: "payment2",
            refundId: nil
        ),
        Booking(
            id: "booking3",
            lessonId: "lesson3",
            instructorId: "instructor1",
            userId: "user1",
            scheduledDate: Date().addingTimeInterval(86400 * 7), // 7 days from now
            status: .pending,
            paymentStatus: .pending,
            totalAmount: 50.0,
            notes: nil,
            createdAt: Date().addingTimeInterval(-86400 * 1), // 1 day ago
            updatedAt: Date().addingTimeInterval(-86400 * 1),
            paymentId: nil,
            refundId: nil
        )
    ]
}