import Foundation
import Security

// MARK: - Session Manager
class SessionManager {
    static let shared = SessionManager()
    
    private let userDefaults = UserDefaults.standard
    private let keychainService = "com.moveup.app"
    
    // Keys
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let userPoints = "userPoints"
        static let userLevel = "userLevel"
        static let userLocation = "userLocation"
        static let userPhone = "userPhone"
        static let userDateOfBirth = "userDateOfBirth"
        static let userCompletedLessonsCount = "userCompletedLessonsCount"
        static let userBadgesCount = "userBadgesCount"
    }
    
    private init() {}
    
    // MARK: - Save Session
    func saveSession(user: User) {
        // Save user data to UserDefaults
        userDefaults.set(true, forKey: Keys.isLoggedIn)
        userDefaults.set(user.email, forKey: Keys.userEmail)
        userDefaults.set(user.name, forKey: Keys.userName)
        userDefaults.set(user.points, forKey: Keys.userPoints)
        userDefaults.set(user.level, forKey: Keys.userLevel)
        userDefaults.set(user.location, forKey: Keys.userLocation)
        userDefaults.set(user.phoneNumber, forKey: Keys.userPhone)
        userDefaults.set(user.dateOfBirth, forKey: Keys.userDateOfBirth)
        userDefaults.set(user.completedLessons.count, forKey: Keys.userCompletedLessonsCount)
        userDefaults.set(user.badges.count, forKey: Keys.userBadgesCount)
        
        userDefaults.synchronize()
    }
    
    // MARK: - Load Session
    func loadSession() -> User? {
        guard userDefaults.bool(forKey: Keys.isLoggedIn),
              let email = userDefaults.string(forKey: Keys.userEmail),
              let name = userDefaults.string(forKey: Keys.userName) else {
            return nil
        }
        
        let points = userDefaults.integer(forKey: Keys.userPoints)
        let level = userDefaults.integer(forKey: Keys.userLevel)
        let location = userDefaults.string(forKey: Keys.userLocation) ?? ""
        let phone = userDefaults.string(forKey: Keys.userPhone) ?? ""
        let dateOfBirth = userDefaults.string(forKey: Keys.userDateOfBirth) ?? ""
        
        // Recreate user - in produzione, dovresti ricaricare i dati completi dal backend
        let user = User(
            name: name,
            email: email,
            profileImageName: "default_profile",
            points: points,
            level: level,
            badges: Badge.sampleBadges, // In produzione: caricare dal backend
            completedLessons: CompletedLesson.sampleLessons, // In produzione: caricare dal backend
            location: location,
            phoneNumber: phone,
            dateOfBirth: dateOfBirth,
            preferredSports: Sport.sampleSports // In produzione: caricare dal backend
        )
        
        return user
    }
    
    // MARK: - Clear Session
    func clearSession() {
        userDefaults.set(false, forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.userEmail)
        userDefaults.removeObject(forKey: Keys.userName)
        userDefaults.removeObject(forKey: Keys.userPoints)
        userDefaults.removeObject(forKey: Keys.userLevel)
        userDefaults.removeObject(forKey: Keys.userLocation)
        userDefaults.removeObject(forKey: Keys.userPhone)
        userDefaults.removeObject(forKey: Keys.userDateOfBirth)
        userDefaults.removeObject(forKey: Keys.userCompletedLessonsCount)
        userDefaults.removeObject(forKey: Keys.userBadgesCount)
        
        userDefaults.synchronize()
    }
    
    // MARK: - Check if logged in
    func isLoggedIn() -> Bool {
        return userDefaults.bool(forKey: Keys.isLoggedIn)
    }
    
    // MARK: - Update specific fields
    func updatePoints(_ points: Int) {
        userDefaults.set(points, forKey: Keys.userPoints)
        userDefaults.synchronize()
    }
    
    func updateLevel(_ level: Int) {
        userDefaults.set(level, forKey: Keys.userLevel)
        userDefaults.synchronize()
    }
    
    func updateLocation(_ location: String) {
        userDefaults.set(location, forKey: Keys.userLocation)
        userDefaults.synchronize()
    }
}
