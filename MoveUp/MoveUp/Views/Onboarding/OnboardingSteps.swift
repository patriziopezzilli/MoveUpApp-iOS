//
//  OnboardingSteps.swift
//  MoveUp
//
//  Created by MoveUp on 14/10/2025.
//

import SwiftUI
import MapKit

// MARK: - Welcome Registration Step
struct WelcomeRegistrationStep: View {
    let userType: UserType
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated Icon
            ZStack {
                Circle()
                    .fill(Color.moveUpPrimary.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(animate ? 1.2 : 1.0)
                    .opacity(animate ? 0 : 1)
                
                Image(systemName: userType == .instructor ? "graduationcap.circle.fill" : "figure.run.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.moveUpPrimary)
                    .scaleEffect(animate ? 1.0 : 0.8)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            
            VStack(spacing: 16) {
                Text(userType == .instructor ? "Diventa Istruttore!" : "Inizia il Tuo Viaggio!")
                    .font(MoveUpFont.title(32))
                    .fontWeight(.bold)
                    .foregroundColor(.moveUpTextPrimary)
                
                Text(userType == .instructor ?
                     "Creiamo insieme il tuo profilo professionale.\nIn pochi passaggi sarai pronto per insegnare!" :
                     "Registrati a MoveUp e scopri le migliori\nlezioni personalizzate per te!"
                )
                .font(MoveUpFont.body())
                .foregroundColor(.moveUpTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }
            
            // Feature highlights
            VStack(alignment: .leading, spacing: 16) {
                OnboardingFeatureRow(
                    icon: userType == .instructor ? "star.fill" : "sparkles",
                    text: userType == .instructor ? "Guadagna insegnando" : "Lezioni personalizzate"
                )
                OnboardingFeatureRow(
                    icon: "calendar.badge.clock",
                    text: userType == .instructor ? "Gestisci la tua agenda" : "Prenota quando vuoi"
                )
                OnboardingFeatureRow(
                    icon: "location.fill",
                    text: userType == .instructor ? "Scegli dove insegnare" : "Trova lezioni vicino a te"
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.moveUpPrimary)
                .frame(width: 30)
            
            Text(text)
                .font(MoveUpFont.body())
                .foregroundColor(.moveUpTextPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Account Creation Step
struct AccountCreationStep: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var acceptTerms: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("📧 Crea il Tuo Account")
                        .font(MoveUpFont.title(24))
                        .fontWeight(.bold)
                    
                    Text("I tuoi dati sono al sicuro con noi")
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpTextSecondary)
                }
                .padding(.top, 32)
                
                VStack(spacing: 20) {
                    // Name Fields
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Nome", systemImage: "person.fill")
                                .font(MoveUpFont.caption())
                                .foregroundColor(.moveUpTextSecondary)
                            
                            TextField("Mario", text: $firstName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(firstName.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Cognome", systemImage: "person.fill")
                                .font(MoveUpFont.caption())
                                .foregroundColor(.moveUpTextSecondary)
                            
                            TextField("Rossi", text: $lastName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(lastName.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Email", systemImage: "envelope.fill")
                            .font(MoveUpFont.caption())
                            .foregroundColor(.moveUpTextSecondary)
                        
                        TextField("mario.rossi@email.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(email.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Password", systemImage: "lock.fill")
                            .font(MoveUpFont.caption())
                            .foregroundColor(.moveUpTextSecondary)
                        
                        SecureField("Almeno 6 caratteri", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(password.isEmpty ? Color.gray.opacity(0.2) : 
                                           (password.count >= 6 ? Color.moveUpPrimary.opacity(0.3) : Color.red.opacity(0.3)), 
                                           lineWidth: 1)
                            )
                        
                        if !password.isEmpty && password.count < 6 {
                            Text("La password deve avere almeno 6 caratteri")
                                .font(MoveUpFont.caption())
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Conferma Password", systemImage: "lock.fill")
                            .font(MoveUpFont.caption())
                            .foregroundColor(.moveUpTextSecondary)
                        
                        SecureField("Ripeti la password", text: $confirmPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(confirmPassword.isEmpty ? Color.gray.opacity(0.2) : 
                                           (password == confirmPassword ? Color.moveUpPrimary.opacity(0.3) : Color.red.opacity(0.3)), 
                                           lineWidth: 1)
                            )
                        
                        if !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Le password non corrispondono")
                                .font(MoveUpFont.caption())
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Terms acceptance
                    Button(action: { acceptTerms.toggle() }) {
                        HStack(spacing: 12) {
                            Image(systemName: acceptTerms ? "checkmark.square.fill" : "square")
                                .font(.title3)
                                .foregroundColor(acceptTerms ? .moveUpPrimary : .gray)
                            
                            (Text("Accetto i ")
                                .foregroundColor(.moveUpTextSecondary)
                             +
                             Text("Termini e Condizioni")
                                .foregroundColor(.moveUpPrimary)
                                .underline()
                             +
                             Text(" e la ")
                                .foregroundColor(.moveUpTextSecondary)
                             +
                             Text("Privacy Policy")
                                .foregroundColor(.moveUpPrimary)
                                .underline()
                            )
                            .font(MoveUpFont.caption())
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

// MARK: - Welcome Step (OLD - da rimuovere)
struct WelcomeStep: View {
    let userType: UserType
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated Icon
            ZStack {
                Circle()
                    .fill(Color.moveUpPrimary.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(animate ? 1.2 : 1.0)
                    .opacity(animate ? 0 : 1)
                
                Image(systemName: userType == .instructor ? "graduationcap.circle.fill" : "figure.run.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.moveUpPrimary)
                    .scaleEffect(animate ? 1.0 : 0.8)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            
            VStack(spacing: 16) {
                Text(userType == .instructor ? "Benvenuto, Istruttore!" : "Benvenuto in MoveUp!")
                    .font(MoveUpFont.title(28))
                    .fontWeight(.bold)
                    .foregroundColor(.moveUpTextPrimary)
                
                Text(userType == .instructor ?
                     "Creiamo insieme il tuo profilo professionale.\nBastano pochi minuti per iniziare." :
                     "Completiamo il tuo profilo per offrirti\nle migliori lezioni personalizzate."
                )
                .font(MoveUpFont.body())
                .foregroundColor(.moveUpTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Profile Photo Step
struct ProfilePhotoStep: View {
    @Binding var profileImage: UIImage?
    @Binding var bio: String
    @State private var showImagePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("📸 Foto Profilo")
                        .font(MoveUpFont.title(24))
                        .fontWeight(.bold)
                    
                    Text("Aggiungi una foto e raccontaci di te")
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpTextSecondary)
                }
                .padding(.top, 32)
                
                // Photo Picker
                Button(action: { showImagePicker = true }) {
                    ZStack {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.moveUpPrimary.opacity(0.1))
                                .frame(width: 150, height: 150)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.moveUpPrimary)
                                        Text("Aggiungi Foto")
                                            .font(MoveUpFont.caption())
                                            .foregroundColor(.moveUpPrimary)
                                    }
                                )
                        }
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.moveUpPrimary, lineWidth: 3)
                    )
                }
                
                // Bio TextField
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bio")
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                    
                    TextEditor(text: $bio)
                        .frame(height: 120)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("\(bio.count)/200 caratteri")
                        .font(MoveUpFont.caption())
                        .foregroundColor(.moveUpTextSecondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
}

// MARK: - Personal Info Step
struct PersonalInfoStep: View {
    @Binding var phoneNumber: String
    @Binding var birthDate: Date
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("👤 Informazioni Personali")
                        .font(MoveUpFont.title(24))
                        .fontWeight(.bold)
                    
                    Text("Aiutaci a conoscerti meglio")
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpTextSecondary)
                }
                .padding(.top, 32)
                
                VStack(spacing: 24) {
                    // Phone Number
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Numero di Telefono", systemImage: "phone.fill")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                        
                        TextField("+39 123 456 7890", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(phoneNumber.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Birth Date
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Data di Nascita", systemImage: "calendar")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                        
                        DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

// MARK: - Sports Selection Step
struct SportsSelectionStep: View {
    @Binding var selectedSports: Set<Sport>
    @Binding var sportSkillLevels: [String: SkillLevel]
    let userType: UserType
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("⚽️ I Tuoi Sport")
                        .font(MoveUpFont.title(24))
                        .fontWeight(.bold)
                    
                    Text(userType == .instructor ?
                         "Quali sport insegni?" :
                         "Quali sport ti interessano?"
                    )
                    .font(MoveUpFont.body())
                    .foregroundColor(.moveUpTextSecondary)
                }
                .padding(.top, 32)
                
                // Sports Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Array(Sport.sampleSports.enumerated()), id: \.element.id) { index, sport in
                        OnboardingSportCard(
                            sport: sport,
                            isSelected: selectedSports.contains(sport)
                        ) {
                            if selectedSports.contains(sport) {
                                selectedSports.remove(sport)
                                sportSkillLevels.removeValue(forKey: sport.id)
                            } else {
                                selectedSports.insert(sport)
                                // Default to beginner for users
                                if userType == .user {
                                    sportSkillLevels[sport.id] = .beginner
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Skill Level per sport (only for users)
                if userType == .user && !selectedSports.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Il tuo livello per ogni sport")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ForEach(Array(selectedSports).sorted(by: { $0.name < $1.name }), id: \.id) { sport in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: sportIcon(for: sport))
                                        .foregroundColor(.moveUpPrimary)
                                        .font(.title3)
                                    Text(sport.name)
                                        .font(MoveUpFont.body())
                                        .fontWeight(.medium)
                                }
                                
                                Picker("Livello \(sport.name)", selection: Binding(
                                    get: { sportSkillLevels[sport.id] ?? .beginner },
                                    set: { sportSkillLevels[sport.id] = $0 }
                                )) {
                                    Text("🟢 Principiante").tag(SkillLevel.beginner)
                                    Text("🟡 Intermedio").tag(SkillLevel.intermediate)
                                    Text("🟠 Avanzato").tag(SkillLevel.advanced)
                                    Text("🔴 Professionista").tag(SkillLevel.professional)
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
    }
    
    private func sportIcon(for sport: Sport) -> String {
        switch sport.name.lowercased() {
        case "tennis": return "tennisball.fill"
        case "padel": return "figure.tennis"
        case "fitness": return "figure.strengthtraining.traditional"
        case "running": return "figure.run"
        case "cycling": return "bicycle"
        case "swimming": return "figure.pool.swim"
        case "yoga": return "figure.yoga"
        case "calcio", "football": return "sportscourt.fill"
        default: return "sportscourt"
        }
    }
}

// MARK: - Sport Selection Card
struct OnboardingSportCard: View {
    let sport: Sport
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: sportIcon(for: sport))
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : .moveUpPrimary)
                
                Text(sport.name)
                    .font(MoveUpFont.body())
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .moveUpTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(isSelected ? Color.moveUpPrimary : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.moveUpPrimary : Color.gray.opacity(0.15), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
    
    private func sportIcon(for sport: Sport) -> String {
        switch sport.name.lowercased() {
        case "tennis": return "tennisball.fill"
        case "padel": return "figure.tennis"
        case "fitness": return "figure.strengthtraining.traditional"
        case "running": return "figure.run"
        case "cycling": return "bicycle"
        case "swimming": return "figure.pool.swim"
        case "yoga": return "figure.yoga"
        case "calcio", "football": return "sportscourt.fill"
        default: return "sportscourt"
        }
    }
}

// MARK: - Location Step
struct LocationStep: View {
    @Binding var location: String
    @Binding var region: MKCoordinateRegion
    @Binding var maxDistance: Double
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("📍 La Tua Posizione")
                        .font(MoveUpFont.title(24))
                        .fontWeight(.bold)
                    
                    Text("Dove vuoi allenarti?")
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpTextSecondary)
                }
                .padding(.top, 32)
                
                // GPS Button
                Button(action: {
                    locationManager.requestCurrentLocation()
                }) {
                    HStack {
                        Image(systemName: locationManager.isLoading ? "location.fill" : "location.circle.fill")
                            .font(.title3)
                        Text(locationManager.isLoading ? "Localizzazione in corso..." : "Usa la mia posizione")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.moveUpPrimary)
                    .cornerRadius(12)
                }
                .disabled(locationManager.isLoading)
                .padding(.horizontal)
                .onChange(of: locationManager.location) { newLocation in
                    if let location = newLocation {
                        region = MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        // Reverse geocoding per ottenere il nome della città
                        locationManager.reverseGeocode(location: location.coordinate) { cityName in
                            self.location = cityName
                        }
                    }
                }
                
                // Manual Location TextField
                VStack(alignment: .leading, spacing: 12) {
                    Label("Oppure inserisci manualmente", systemImage: "mappin.circle.fill")
                        .font(MoveUpFont.caption())
                        .foregroundColor(.moveUpTextSecondary)
                    
                    TextField("es. Roma, Milano, Napoli...", text: $location)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(location.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                // Distance Slider
                VStack(alignment: .leading, spacing: 16) {
                    Label("Distanza Massima", systemImage: "arrow.left.and.right.circle.fill")
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(Int(maxDistance)) km")
                                .font(MoveUpFont.title(20))
                                .fontWeight(.bold)
                                .foregroundColor(.moveUpPrimary)
                            Spacer()
                        }
                        
                        Slider(value: $maxDistance, in: 1...50, step: 1)
                            .accentColor(.moveUpPrimary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Map Preview
                Map(coordinateRegion: $region, interactionModes: [])
                    .frame(height: 200)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 2)
                    )
                    .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

// MARK: - Certifications Step (Instructor)
struct CertificationsStep: View {
    @Binding var certifications: [String]
    @Binding var experience: String
    @State private var newCertification = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("🏆 Certificazioni")
                        .font(MoveUpFont.title(24))
                        .fontWeight(.bold)
                    
                    Text("Le tue qualifiche professionali")
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpTextSecondary)
                }
                .padding(.top, 32)
                
                // Add Certification
                VStack(alignment: .leading, spacing: 12) {
                    Label("Aggiungi Certificazione", systemImage: "plus.circle.fill")
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        TextField("es. Personal Trainer certificato ISSA", text: $newCertification)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        Button(action: {
                            if !newCertification.isEmpty {
                                certifications.append(newCertification)
                                newCertification = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.moveUpPrimary)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Certifications List
                if !certifications.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(certifications, id: \.self) { cert in
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.moveUpAccent1)
                                Text(cert)
                                    .font(MoveUpFont.body())
                                Spacer()
                                Button(action: {
                                    certifications.removeAll { $0 == cert }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Experience
                VStack(alignment: .leading, spacing: 12) {
                    Label("Anni di Esperienza", systemImage: "clock.fill")
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                    
                    TextField("es. 5", text: $experience)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(experience.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

// MARK: - Pricing Step (Instructor)
struct PricingStep: View {
    @Binding var hourlyRate: String
    
    private var rateValue: Double {
        Double(hourlyRate) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("💰 Tariffa Oraria")
                    .font(MoveUpFont.title(24))
                    .fontWeight(.bold)
                
                Text("Quanto vuoi guadagnare per ora?")
                    .font(MoveUpFont.body())
                    .foregroundColor(.moveUpTextSecondary)
            }
            
            // Big Price Input
            HStack(spacing: 8) {
                Text("€")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.moveUpPrimary)
                
                TextField("45", text: $hourlyRate)
                    .keyboardType(.numberPad)
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.moveUpPrimary)
                    .multilineTextAlignment(.center)
                    .frame(width: 150)
                
                Text("/ora")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.moveUpTextSecondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            
            // Real-time Fee Breakdown (only if rate > 0)
            if rateValue > 0 {
                VStack(spacing: 16) {
                    Text("Quanto riceverai realmente:")
                        .font(MoveUpFont.caption())
                        .foregroundColor(.moveUpTextSecondary)
                    
                    CompactFeeBreakdownView(grossAmount: rateValue)
                }
                .transition(.opacity.combined(with: .scale))
            }
            
            Text("Potrai modificarla in seguito")
                .font(MoveUpFont.caption())
                .foregroundColor(.moveUpTextSecondary)
            
            Spacer()
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: rateValue > 0)
    }
}

// MARK: - Notifications Step
struct NotificationsStep: View {
    @Binding var notificationsEnabled: Bool
    @Binding var marketingEnabled: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.moveUpPrimary)
                
                Text("🔔 Notifiche")
                    .font(MoveUpFont.title(24))
                    .fontWeight(.bold)
                
                Text("Rimani aggiornato sulle tue attività")
                    .font(MoveUpFont.body())
                    .foregroundColor(.moveUpTextSecondary)
            }
            
            VStack(spacing: 20) {
                OnboardingNotificationToggle(
                    icon: "calendar.badge.clock",
                    title: "Promemoria Lezioni",
                    subtitle: "Ricevi notifiche prima delle lezioni",
                    isOn: $notificationsEnabled
                )
                
                OnboardingNotificationToggle(
                    icon: "megaphone.fill",
                    title: "Offerte e Novità",
                    subtitle: "Scopri nuove lezioni e promozioni",
                    isOn: $marketingEnabled
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Notification Toggle
struct OnboardingNotificationToggle: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.moveUpPrimary)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MoveUpFont.body())
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(MoveUpFont.caption())
                    .foregroundColor(.moveUpTextSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.moveUpPrimary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
