import Foundation
import Combine

// MARK: - Date Extensions
extension Date {
    func formatted(_ style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: self)
    }
    
    func timeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    var initials: String {
        let components = self.split(separator: " ")
        return components.compactMap { $0.first?.uppercased() }.joined()
    }
}

// MARK: - Double Extensions
extension Double {
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: NSNumber(value: self)) ?? "€0,00"
    }
    
    func distanceFormatted() -> String {
        if self < 1 {
            return String(format: "%.0fm", self * 1000)
        } else {
            return String(format: "%.1fkm", self)
        }
    }
}

// MARK: - Array Extensions
extension Array where Element == Sport {
    func filtered(by category: SportCategory) -> [Sport] {
        return self.filter { $0.category == category }
    }
}

// MARK: - UserDefaults Helper
class UserDefaultsHelper {
    static let shared = UserDefaultsHelper()
    
    private init() {}
    
    private enum Keys {
        static let isFirstLaunch = "isFirstLaunch"
        static let currentUserId = "currentUserId"
        static let userPreferences = "userPreferences"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    var isFirstLaunch: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isFirstLaunch) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isFirstLaunch) }
    }
    
    var currentUserId: String? {
        get { UserDefaults.standard.string(forKey: Keys.currentUserId) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.currentUserId) }
    }
    
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: Keys.currentUserId)
        UserDefaults.standard.removeObject(forKey: Keys.userPreferences)
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
    }
}

// MARK: - Location Helper
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var totalDistanceTraveled: Double = 0.0
    @Published var isLocationEnabled: Bool = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var lastKnownLocation: CLLocation?
    
    // Computed property per compatibilità con MapView
    var userLocation: CLLocation? {
        return location
    }
    
    // Computed property per compatibilità con MapView
    var locationPermissionStatus: CLAuthorizationStatus {
        return authorizationStatus
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10 // Update ogni 10 metri
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func requestLocationPermission() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    private func startLocationUpdates() {
        guard manager.authorizationStatus == .authorizedWhenInUse || 
              manager.authorizationStatus == .authorizedAlways else {
            return
        }
        
        manager.startUpdatingLocation()
        isLocationEnabled = true
    }
    
    private func stopLocationUpdates() {
        manager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    func calculateDistanceFromHome(homeLocation: CLLocation) -> Double {
        guard let currentLocation = location else { return 0 }
        return currentLocation.distance(from: homeLocation)
    }
    
    func isWithinRadius(_ radius: Double, from centerLocation: CLLocation) -> Bool {
        guard let currentLocation = location else { return false }
        return currentLocation.distance(from: centerLocation) <= radius
    }
    
    func requestCurrentLocation() {
        isLoading = true
        errorMessage = nil
        
        // Check authorization status
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Permesso di localizzazione negato. Abilita la localizzazione nelle Impostazioni."
            isLoading = false
        @unknown default:
            errorMessage = "Errore sconosciuto."
            isLoading = false
        }
    }
    
    func reverseGeocode(location: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let error = error {
                print("❌ Reverse geocoding error: \(error.localizedDescription)")
                completion("Posizione sconosciuta")
                return
            }
            
            if let placemark = placemarks?.first {
                // Prova a ottenere città, altrimenti località, altrimenti paese
                let city = placemark.locality ?? placemark.administrativeArea ?? placemark.country ?? "Posizione sconosciuta"
                completion(city)
            } else {
                completion("Posizione sconosciuta")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // Aggiorna la posizione corrente
        DispatchQueue.main.async {
            self.location = newLocation
            self.currentLocation = newLocation.coordinate
            self.isLoading = false
        }
        
        // Calcola la distanza percorsa
        if let lastLocation = lastKnownLocation {
            let distance = newLocation.distance(from: lastLocation)
            
            // Aggiorna solo se la distanza è significativa (evita errori GPS)
            if distance > 5 && distance < 1000 {
                DispatchQueue.main.async {
                    self.totalDistanceTraveled += distance
                }
            }
        }
        
        lastKnownLocation = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "Errore nella localizzazione: \(error.localizedDescription)"
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            stopLocationUpdates()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func distance(from location: LocationData) -> Double {
        guard let currentLocation = self.location else { return Double.infinity }
        let lessonLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return currentLocation.distance(from: lessonLocation) / 1000 // Convert to km
    }
    
    // MARK: - Extensions per utility
    func formatDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            return String(format: "%.1f km", distance / 1000)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
    
    func resetTotalDistance() {
        totalDistanceTraveled = 0.0
    }
    
    var currentLocationString: String {
        guard let location = location else {
            return "Posizione non disponibile"
        }
        
        return String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
    }
}

// MARK: - Validation Helper
struct ValidationHelper {
    static func validatePassword(_ password: String) -> String? {
        if password.count < 6 {
            return "La password deve contenere almeno 6 caratteri"
        }
        return nil
    }
    
    static func validateEmail(_ email: String) -> String? {
        if !email.isValidEmail {
            return "Inserisci un indirizzo email valido"
        }
        return nil
    }
    
    static func validateName(_ name: String) -> String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Questo campo è obbligatorio"
        }
        if name.count < 2 {
            return "Il nome deve contenere almeno 2 caratteri"
        }
        return nil
    }
    
    static func validatePhoneNumber(_ phone: String) -> String? {
        let cleanedPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if cleanedPhone.count < 10 {
            return "Inserisci un numero di telefono valido"
        }
        return nil
    }
}

// MARK: - Analytics Helper
class AnalyticsHelper {
    static let shared = AnalyticsHelper()
    
    private init() {}
    
    func track(event: String, parameters: [String: Any]? = nil) {
        // In a real app, this would integrate with Firebase Analytics, Mixpanel, etc.
        print("Analytics Event: \(event)")
        if let params = parameters {
            print("Parameters: \(params)")
        }
    }
    
    func trackUserAction(_ action: UserAction) {
        track(event: action.eventName, parameters: action.parameters)
    }
}

enum UserAction {
    case signUp(userType: UserType)
    case signIn
    case lessonSearch(sport: String?)
    case lessonBooked(lessonId: String, instructorId: String)
    case reviewSubmitted(rating: Int)
    case profileCompleted
    
    var eventName: String {
        switch self {
        case .signUp: return "user_sign_up"
        case .signIn: return "user_sign_in"
        case .lessonSearch: return "lesson_search"
        case .lessonBooked: return "lesson_booked"
        case .reviewSubmitted: return "review_submitted"
        case .profileCompleted: return "profile_completed"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .signUp(let userType):
            return ["user_type": userType.rawValue]
        case .signIn:
            return [:]
        case .lessonSearch(let sport):
            return ["sport": sport ?? "all"]
        case .lessonBooked(let lessonId, let instructorId):
            return ["lesson_id": lessonId, "instructor_id": instructorId]
        case .reviewSubmitted(let rating):
            return ["rating": rating]
        case .profileCompleted:
            return [:]
        }
    }
}
