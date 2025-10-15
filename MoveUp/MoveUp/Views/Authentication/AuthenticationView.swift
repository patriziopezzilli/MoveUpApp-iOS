import SwiftUI

struct AuthenticationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @State private var isSignUp = false
    @State private var selectedUserType: UserType = .user
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var acceptTerms = false
    @State private var showOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.moveUpBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: MoveUpSpacing.large) {
                        // Header
                        VStack(spacing: MoveUpSpacing.medium) {
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color.moveUpPrimary)
                            
                            Text(isSignUp ? "Registrati" : "Accedi")
                                .font(MoveUpFont.title())
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            if !isSignUp {
                                Text("Bentornato in MoveUp!")
                                    .font(MoveUpFont.body())
                                    .foregroundColor(Color.moveUpTextSecondary)
                            }
                        }
                        .padding(.top, MoveUpSpacing.large)
                        
                        // User Type Selection (Sign Up only)
                        if isSignUp {
                            VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
                                Text("Tipo di account")
                                    .font(MoveUpFont.subtitle(16))
                                    .foregroundColor(Color.moveUpTextPrimary)
                                
                                HStack(spacing: MoveUpSpacing.medium) {
                                    UserTypeCard(
                                        userType: .user,
                                        selectedType: $selectedUserType,
                                        title: "Utente",
                                        subtitle: "Prenota lezioni",
                                        iconName: "person.fill"
                                    )
                                    
                                    UserTypeCard(
                                        userType: .instructor,
                                        selectedType: $selectedUserType,
                                        title: "Istruttore",
                                        subtitle: "Offri lezioni",
                                        iconName: "graduationcap.fill"
                                    )
                                }
                            }
                        }
                        
                        // Form Fields
                        VStack(spacing: MoveUpSpacing.medium) {
                            if isSignUp {
                                HStack(spacing: MoveUpSpacing.medium) {
                                    CustomTextField(
                                        text: $firstName,
                                        placeholder: "Nome",
                                        iconName: "person"
                                    )
                                    
                                    CustomTextField(
                                        text: $lastName,
                                        placeholder: "Cognome",
                                        iconName: "person"
                                    )
                                }
                            }
                            
                            CustomTextField(
                                text: $email,
                                placeholder: "Email",
                                iconName: "envelope",
                                keyboardType: .emailAddress
                            )
                            
                            CustomTextField(
                                text: $password,
                                placeholder: "Password",
                                iconName: "lock",
                                isSecure: true
                            )
                            
                            if isSignUp {
                                CustomTextField(
                                    text: $confirmPassword,
                                    placeholder: "Conferma Password",
                                    iconName: "lock",
                                    isSecure: true
                                )
                                
                                HStack {
                                    Button(action: {
                                        acceptTerms.toggle()
                                    }) {
                                        Image(systemName: acceptTerms ? "checkmark.square.fill" : "square")
                                            .foregroundColor(acceptTerms ? Color.moveUpPrimary : .gray)
                                    }
                                    
                                    Text("Accetto i ")
                                        .font(MoveUpFont.caption())
                                        .foregroundColor(Color.moveUpTextSecondary)
                                    +
                                    Text("Termini e Condizioni")
                                        .font(MoveUpFont.caption())
                                        .foregroundColor(Color.moveUpPrimary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, MoveUpSpacing.small)
                            }
                        }
                        
                        // Error Message
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpError)
                                .moveUpCard(backgroundColor: Color.moveUpError.opacity(0.1))
                                .padding(.horizontal, MoveUpSpacing.medium)
                                .padding(.vertical, MoveUpSpacing.small)
                        }
                        
                        // Action Button
                        Button(action: handleAuthentication) {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(isSignUp ? "Registrati" : "Accedi")
                                    .font(MoveUpFont.button())
                            }
                        }
                        .buttonStyle(MoveUpButtonStyle(
                            backgroundColor: isSignUp ? 
                                (selectedUserType == .instructor ? Color.moveUpPrimary : Color.moveUpSecondary) : 
                                Color.moveUpPrimary,
                            foregroundColor: .white
                        ))
                        .disabled(authViewModel.isLoading || !isFormValid)
                        
                        // Toggle between Sign In / Sign Up
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isSignUp.toggle()
                                clearForm()
                            }
                        }) {
                            Text(isSignUp ? "Hai già un account? Accedi" : "Non hai un account? Registrati")
                                .font(MoveUpFont.body())
                                .foregroundColor(Color.moveUpPrimary)
                        }
                        .padding(.top, MoveUpSpacing.medium)
                        
                        Spacer(minLength: MoveUpSpacing.large)
                    }
                    .padding(.horizontal, MoveUpSpacing.large)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundColor(Color.moveUpPrimary)
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingFlow(userType: selectedUserType)
                    .environmentObject(authViewModel)
            }
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !firstName.isEmpty &&
                   !lastName.isEmpty &&
                   !email.isEmpty &&
                   !password.isEmpty &&
                   password == confirmPassword &&
                   acceptTerms &&
                   password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handleAuthentication() {
        if isSignUp {
            authViewModel.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            
            // Mostra onboarding dopo registrazione riuscita
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if authViewModel.isAuthenticated {
                    showOnboarding = true
                }
            }
        } else {
            authViewModel.signIn(email: email, password: password)
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
        acceptTerms = false
        authViewModel.errorMessage = nil
    }
}

struct UserTypeCard: View {
    let userType: UserType
    @Binding var selectedType: UserType
    let title: String
    let subtitle: String
    let iconName: String
    
    var isSelected: Bool {
        selectedType == userType
    }
    
    var body: some View {
        Button(action: {
            selectedType = userType
        }) {
            VStack(spacing: MoveUpSpacing.small) {
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : (userType == .instructor ? Color.moveUpPrimary : Color.moveUpSecondary))
                
                Text(title)
                    .font(MoveUpFont.subtitle(16))
                    .foregroundColor(isSelected ? .white : Color.moveUpTextPrimary)
                
                Text(subtitle)
                    .font(MoveUpFont.caption())
                    .foregroundColor(isSelected ? .white.opacity(0.8) : Color.moveUpTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(MoveUpSpacing.medium)
            .background(
                isSelected ? 
                (userType == .instructor ? Color.moveUpPrimary : Color.moveUpSecondary) :
                    Color.moveUpCardBackground
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? .clear : (userType == .instructor ? Color.moveUpPrimary : Color.moveUpSecondary),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let iconName: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: MoveUpSpacing.medium) {
            Image(systemName: iconName)
                .foregroundColor(Color.moveUpTextSecondary)
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .font(MoveUpFont.body())
        }
        .padding(MoveUpSpacing.medium)
        .background(Color.moveUpCardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
    }
}
