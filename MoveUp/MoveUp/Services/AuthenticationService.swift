import Foundation
import Combine

// MARK: - Authentication Service
class AuthenticationService {
    
    enum AuthError: Error, LocalizedError {
        case invalidCredentials
        case userNotFound
        case emailAlreadyExists
        case weakPassword
        case networkError
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Credenziali non valide"
            case .userNotFound:
                return "Utente non trovato"
            case .emailAlreadyExists:
                return "Email già registrata"
            case .weakPassword:
                return "Password troppo debole"
            case .networkError:
                return "Errore di connessione"
            }
        }
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<User, AuthError> {
        // Simulate API call
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Mock authentication - in real app, this would call your backend
                if email.lowercased() == "test@moveup.com" && password == "password" {
                    let user = User.sampleUser
                    promise(.success(user))
                } else if email.lowercased() == "instructor@moveup.com" && password == "password" {
                    let user = User(
                        name: "Marco Santini",
                        email: email,
                        profileImageName: "instructor_sample",
                        points: 1250,
                        level: 8,
                        badges: Badge.sampleBadges,
                        completedLessons: [],
                        location: "Milano, Italia",
                        phoneNumber: "+39 335 567 8901",
                        dateOfBirth: "22/08/1985",
                        preferredSports: [Sport.sampleSports[0]] // Tennis
                    )
                    promise(.success(user))
                } else {
                    promise(.failure(.invalidCredentials))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) -> AnyPublisher<User, AuthError> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Mock registration - validate basic requirements
                guard password.count >= 6 else {
                    promise(.failure(.weakPassword))
                    return
                }
                
                let user = User(
                    name: "\(firstName) \(lastName)",
                    email: email,
                    profileImageName: "default_profile",
                    points: 0,
                    level: 1,
                    badges: [],
                    completedLessons: [],
                    location: "Italia",
                    phoneNumber: "",
                    dateOfBirth: "",
                    preferredSports: []
                )
                promise(.success(user))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Never> {
        return Future { promise in
            // Clear stored tokens/credentials
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, AuthError> {
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Mock password reset
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Mock Data Service
class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    // Mock users
    lazy var mockUsers: [User] = [
        User(
            name: "Mario Rossi",
            email: "mario.rossi@email.com",
            profileImageName: "profile_1",
            points: 1200,
            level: 3,
            badges: Array(Badge.sampleBadges.prefix(2)),
            completedLessons: Array(CompletedLesson.sampleLessons.prefix(1)),
            location: "Roma, Italia",
            phoneNumber: "+39 333 111 2222",
            dateOfBirth: "10/05/1988",
            preferredSports: [Sport.sampleSports[1]] // Calcio
        ),
        User(
            name: "Giulia Verdi",
            email: "giulia.verdi@email.com",
            profileImageName: "profile_2",
            points: 800,
            level: 2,
            badges: Array(Badge.sampleBadges.prefix(1)),
            completedLessons: [],
            location: "Napoli, Italia",
            phoneNumber: "+39 334 222 3333",
            dateOfBirth: "25/11/1992",
            preferredSports: [Sport.sampleSports[2]] // Nuoto
        )
    ]
    
    // Mock instructors
    lazy var mockInstructors: [Instructor] = [
        Instructor(
            id: "1",
            userId: "instructor1",
            bio: "Istruttore di tennis con 10 anni di esperienza. Specializzato in tecniche avanzate e preparazione atletica.",
            specializations: [Sport.sampleSports[0]],
            certifications: [],
            hourlyRate: 45.0,
            availability: [],
            location: LocationData(latitude: 41.9028, longitude: 12.4964, address: "Via del Corso, 123", city: "Roma", region: "Lazio", country: "Italia"),
            isApproved: true,
            rating: 4.8,
            totalLessons: 156,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Instructor(
            id: "2",
            userId: "instructor2",
            bio: "Personal trainer certificato con focus su fitness funzionale e allenamento personalizzato.",
            specializations: [Sport.sampleSports[3]],
            certifications: [],
            hourlyRate: 35.0,
            availability: [],
            location: LocationData(latitude: 45.4642, longitude: 9.1900, address: "Corso Buenos Aires, 45", city: "Milano", region: "Lombardia", country: "Italia"),
            isApproved: true,
            rating: 4.9,
            totalLessons: 203,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    // Mock lessons
    lazy var mockLessons: [Lesson] = [
        Lesson(
            id: "1",
            instructorId: "1",
            sport: Sport.sampleSports[0],
            title: "Lezione di Tennis Individuale",
            description: "Migliora la tua tecnica con lezioni personalizzate. Perfetto per principianti e livelli intermedi.",
            price: 45.0,
            duration: 3600, // 1 hour
            location: LocationData(latitude: 41.9028, longitude: 12.4964, address: "Tennis Club Roma", city: "Roma", region: "Lazio", country: "Italia"),
            skillLevel: .intermediate,
            equipment: ["Racchetta", "Palline da tennis"],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Lesson(
            id: "2",
            instructorId: "2",
            sport: Sport.sampleSports[3],
            title: "Personal Training Fitness",
            description: "Allenamento personalizzato per raggiungere i tuoi obiettivi fitness in modo efficace e sicuro.",
            price: 35.0,
            duration: 2700, // 45 minutes
            location: LocationData(latitude: 45.4642, longitude: 9.1900, address: "Palestra FitZone", city: "Milano", region: "Lombardia", country: "Italia"),
            skillLevel: .beginner,
            equipment: ["Abbigliamento sportivo", "Asciugamano"],
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}