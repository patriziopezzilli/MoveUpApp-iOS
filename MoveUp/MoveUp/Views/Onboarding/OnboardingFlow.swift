//
//  OnboardingFlow.swift
//  MoveUp
//
//  Created by MoveUp on 14/10/2025.
//

import SwiftUI
import MapKit

// MARK: - Onboarding Coordinator (Registrazione Guidata)
struct OnboardingFlow: View {
    let userType: UserType
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var progress: Double = 0
    @State private var showCompletion = false
    
    // Authentication Data
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var acceptTerms = false
    
    // Profile Data
    @State private var profileImage: UIImage?
    @State private var bio = ""
    @State private var phoneNumber = ""
    @State private var birthDate = Date()
    @State private var selectedSports: Set<Sport> = []
    @State private var sportSkillLevels: [String: SkillLevel] = [:]
    @State private var location = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var maxDistance: Double = 10
    @State private var notificationsEnabled = true
    @State private var marketingEnabled = false
    
    // Instructor specific
    @State private var certifications: [String] = []
    @State private var experience = ""
    @State private var hourlyRate = ""
    
    var totalSteps: Int {
        userType == .instructor ? 8 : 6
    }
    
    var body: some View {
        ZStack {
            // Clean white background
            Color.moveUpBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Logo
                HStack {
                    Image(systemName: "figure.run.circle.fill")
                        .font(.title)
                        .foregroundColor(.moveUpPrimary)
                    Text("MoveUp")
                        .font(MoveUpFont.title(20))
                        .foregroundColor(.moveUpTextPrimary)
                    Spacer()
                    if currentStep > 0 {
                        Button("Esci") {
                            dismiss()
                        }
                        .font(MoveUpFont.caption())
                        .foregroundColor(.moveUpTextSecondary)
                    }
                }
                .padding()
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.05))
                        .frame(height: 1),
                    alignment: .bottom
                )
                
                // Progress Bar
                OnboardingProgressBar(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    progress: progress
                )
                .padding(.horizontal)
                .padding(.vertical, 16)
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 0: Welcome & User Type
                    WelcomeRegistrationStep(userType: userType)
                        .tag(0)
                    
                    // Step 1: Account Creation (Email & Password)
                    AccountCreationStep(
                        email: $email,
                        password: $password,
                        confirmPassword: $confirmPassword,
                        firstName: $firstName,
                        lastName: $lastName,
                        acceptTerms: $acceptTerms
                    )
                    .tag(1)
                    
                    // Step 2: Profile Photo & Bio
                    ProfilePhotoStep(
                        profileImage: $profileImage,
                        bio: $bio
                    )
                    .tag(2)
                    
                    // Step 3: Personal Info
                    PersonalInfoStep(
                        phoneNumber: $phoneNumber,
                        birthDate: $birthDate
                    )
                    .tag(3)
                    
                    // Step 4: Sports Selection
                    SportsSelectionStep(
                        selectedSports: $selectedSports,
                        sportSkillLevels: $sportSkillLevels,
                        userType: userType
                    )
                    .tag(4)
                    
                    // Step 5: Location
                    LocationStep(
                        location: $location,
                        region: $region,
                        maxDistance: $maxDistance
                    )
                    .tag(5)
                    
                    if userType == .instructor {
                        // Step 6: Certifications (Instructor only)
                        CertificationsStep(
                            certifications: $certifications,
                            experience: $experience
                        )
                        .tag(6)
                        
                        // Step 7: Pricing (Instructor only)
                        PricingStep(hourlyRate: $hourlyRate)
                            .tag(7)
                    }
                    
                    // Final Step: Notifications
                    NotificationsStep(
                        notificationsEnabled: $notificationsEnabled,
                        marketingEnabled: $marketingEnabled
                    )
                    .tag(userType == .instructor ? 8 : 6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation Buttons
                OnboardingNavigationButtons(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    isValid: isCurrentStepValid,
                    onBack: goBack,
                    onNext: goNext,
                    onComplete: completeRegistration
                )
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onChange(of: currentStep) { newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = Double(newValue) / Double(totalSteps)
            }
        }
        .fullScreenCover(isPresented: $showCompletion) {
            OnboardingCompletionView(userType: userType)
                .onDisappear {
                    dismiss()
                }
        }
    }
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && 
                       !password.isEmpty && password == confirmPassword && 
                       password.count >= 6 && acceptTerms
        case 2: return !bio.isEmpty
        case 3: return !phoneNumber.isEmpty
        case 4: return !selectedSports.isEmpty
        case 5: return !location.isEmpty
        case 6: return userType == .user || !certifications.isEmpty
        case 7: return userType == .user || !hourlyRate.isEmpty
        default: return true
        }
    }
    
    private func goBack() {
        withAnimation {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
    
    private func goNext() {
        withAnimation {
            if currentStep < totalSteps {
                currentStep += 1
            }
        }
    }
    
    private func completeRegistration() {
        // Crea l'account
        authViewModel.signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        
        // Salva tutti i dati del profilo
        saveProfileData()
        
        // Mostra schermata di completamento
        withAnimation {
            showCompletion = true
        }
    }
    
    private func saveProfileData() {
        // TODO: Save to backend/UserDefaults
        print("💾 Saving complete profile...")
        print("Account: \(email)")
        print("Name: \(firstName) \(lastName)")
        print("Bio: \(bio)")
        print("Phone: \(phoneNumber)")
        print("Sports: \(selectedSports.map { $0.name })")
        print("Sport Skill Levels: \(sportSkillLevels)")
        print("Location: \(location)")
        
        if userType == .instructor {
            print("Certifications: \(certifications)")
            print("Hourly Rate: \(hourlyRate)")
        }
    }
}

// MARK: - Progress Bar
struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Passo \(currentStep + 1) di \(totalSteps + 1)")
                    .font(MoveUpFont.caption())
                    .foregroundColor(.moveUpTextSecondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(MoveUpFont.caption())
                    .fontWeight(.semibold)
                    .foregroundColor(.moveUpPrimary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.moveUpPrimary)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Navigation Buttons
struct OnboardingNavigationButtons: View {
    let currentStep: Int
    let totalSteps: Int
    let isValid: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            if currentStep > 0 {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Indietro")
                    }
                    .font(MoveUpFont.body())
                    .foregroundColor(.moveUpPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.moveUpPrimary, lineWidth: 2)
                    )
                }
            }
            
            Button(action: {
                if currentStep == totalSteps {
                    onComplete()
                } else {
                    onNext()
                }
            }) {
                HStack {
                    Text(currentStep == totalSteps ? "Completa" : "Avanti")
                    Image(systemName: currentStep == totalSteps ? "checkmark" : "chevron.right")
                }
                .font(MoveUpFont.body())
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? Color.moveUpPrimary : Color.gray.opacity(0.3))
                .cornerRadius(12)
            }
            .disabled(!isValid)
        }
    }
}

// MARK: - Completion View
struct OnboardingCompletionView: View {
    let userType: UserType
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Success Animation
                ZStack {
                    Circle()
                        .fill(Color.moveUpPrimary.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .scaleEffect(scale)
                    
                    Circle()
                        .fill(Color.moveUpPrimary.opacity(0.05))
                        .frame(width: 220, height: 220)
                        .scaleEffect(scale * 0.9)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.moveUpPrimary)
                        .scaleEffect(scale)
                }
                
                VStack(spacing: 16) {
                    Text("Complimenti! 🎉")
                        .font(MoveUpFont.title(32))
                        .fontWeight(.bold)
                        .foregroundColor(.moveUpTextPrimary)
                    
                    Text(userType == .instructor ?
                         "Il tuo profilo istruttore è pronto!\nInizia a condividere la tua passione." :
                         "Il tuo profilo è completo!\nSei pronto per la tua prima lezione."
                    )
                    .font(MoveUpFont.body())
                    .foregroundColor(.moveUpTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                }
                .opacity(opacity)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
                opacity = 1.0
            }
        }
    }
}
