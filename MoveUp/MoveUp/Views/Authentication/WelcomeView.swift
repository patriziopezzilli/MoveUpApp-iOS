import SwiftUI

struct WelcomeView: View {
    @State private var currentPage = 0
    @State private var showUserRegistration = false
    @State private var showInstructorRegistration = false
    @State private var showLogin = false
    
    private let onboardingPages = [
        OnboardingPage(
            title: "Trova il tuo istruttore",
            subtitle: "Scopri istruttori qualificati vicino a te per lezioni personalizzate",
            imageName: "map.fill",
            color: Color.moveUpSecondary
        ),
        OnboardingPage(
            title: "Prenota in sicurezza",
            subtitle: "Sistema di pagamento sicuro con protezione acquirente integrata",
            imageName: "lock.shield.fill",
            color: Color.moveUpAccent2
        ),
        OnboardingPage(
            title: "Guadagna punti",
            subtitle: "Accumula punti ad ogni lezione e sblocca premi esclusivi",
            imageName: "star.fill",
            color: .moveUpGamification
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.moveUpBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo and Brand
                    VStack(spacing: MoveUpSpacing.medium) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color.moveUpPrimary)
                        
                        Text("MoveUp")
                            .font(MoveUpFont.title(32))
                            .foregroundColor(Color.moveUpPrimary)
                        
                        Text("La tua piattaforma per lezioni sportive")
                            .font(MoveUpFont.body())
                            .foregroundColor(Color.moveUpTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, MoveUpSpacing.xxl)
                    
                    Spacer()
                    
                    // Onboarding Pages
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            OnboardingPageView(page: onboardingPages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 300)
                    .onAppear {
                        // Auto-advance pages
                        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentPage = (currentPage + 1) % onboardingPages.count
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Call to Action Buttons
                    VStack(spacing: MoveUpSpacing.medium) {
                        Button("Inizia come Utente") {
                            showUserRegistration = true
                        }
                        .buttonStyle(MoveUpButtonStyle(
                            backgroundColor: Color.moveUpSecondary,
                            foregroundColor: .white
                        ))
                        
                        Button("Sono un Istruttore") {
                            showInstructorRegistration = true
                        }
                        .buttonStyle(MoveUpSecondaryButtonStyle(
                            borderColor: Color.moveUpPrimary,
                            foregroundColor: Color.moveUpPrimary
                        ))
                        
                        Button("Accedi") {
                            showLogin = true
                        }
                        .font(MoveUpFont.button())
                        .foregroundColor(Color.moveUpTextSecondary)
                        .padding(.top, MoveUpSpacing.small)
                    }
                    .padding(.horizontal, MoveUpSpacing.large)
                    .padding(.bottom, MoveUpSpacing.xxl)
                }
            }
        }
        .fullScreenCover(isPresented: $showUserRegistration) {
            OnboardingFlow(userType: .user)
        }
        .fullScreenCover(isPresented: $showInstructorRegistration) {
            OnboardingFlow(userType: .instructor)
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: MoveUpSpacing.large) {
            Image(systemName: page.imageName)
                .font(.system(size: 60))
                .foregroundColor(page.color)
                .frame(width: 120, height: 120)
                .background(page.color.opacity(0.1))
                .cornerRadius(60)
            
            VStack(spacing: MoveUpSpacing.small) {
                Text(page.title)
                    .font(MoveUpFont.subtitle())
                    .foregroundColor(Color.moveUpTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MoveUpSpacing.large)
            }
        }
        .padding(MoveUpSpacing.large)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
