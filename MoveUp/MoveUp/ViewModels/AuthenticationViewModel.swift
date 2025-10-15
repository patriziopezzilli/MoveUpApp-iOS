import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthenticationService()
    private let sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    func checkAuthenticationStatus() {
        isLoading = true
        
        // Check if user has a saved session
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            
            if let savedUser = self.sessionManager.loadSession() {
                // User has a saved session - restore it
                self.currentUser = savedUser
                self.isAuthenticated = true
            } else {
                // No saved session
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { user in
                    self.currentUser = user
                    self.isAuthenticated = true
                    
                    // Save session for auto-login
                    self.sessionManager.saveSession(user: user)
                }
            )
            .store(in: &cancellables)
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) {
        isLoading = true
        errorMessage = nil
        
        authService.signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { user in
                self.currentUser = user
                self.isAuthenticated = true
                
                // Save session for auto-login
                self.sessionManager.saveSession(user: user)
            }
        )
        .store(in: &cancellables)
    }
    
    func signOut() {
        authService.signOut()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    // Clear session
                    self.sessionManager.clearSession()
                    
                    self.currentUser = nil
                    self.isAuthenticated = false
                }
            )
            .store(in: &cancellables)
    }
    
    func resetPassword(email: String) {
        authService.resetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    // Show success message
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Update Session
    /// Call this method whenever user data changes (points, badges, etc.)
    func updateSession() {
        if let user = currentUser {
            sessionManager.saveSession(user: user)
        }
    }
}