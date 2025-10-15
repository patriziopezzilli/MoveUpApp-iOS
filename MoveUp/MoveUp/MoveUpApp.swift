import SwiftUI

@main
struct MoveUpApp: App {
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authenticationViewModel)
        }
    }
}