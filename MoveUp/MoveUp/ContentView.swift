import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.currentUser?.email.contains("instructor") == true {
                    InstructorTabView()
                } else {
                    UserTabView()
                }
            } else {
                NavigationStack {
                    WelcomeView()
                }
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}