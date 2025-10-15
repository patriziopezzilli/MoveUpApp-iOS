import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @Environment(\.dismiss) private var dismiss
    @State private var showBooking = false
    @State private var showContactInstructor = false
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlot?
    
    // Mock instructor data - in real app would be fetched
    private let instructor = MockDataService.shared.mockInstructors.first!
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MoveUpSpacing.large) {
                // Lesson Info Section (Banner rimosso)
                VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(lesson.title)
                                .font(MoveUpFont.title())
                                .foregroundColor(Color.moveUpPrimary)
                            
                            Text("con Marco Trainer")
                                .font(MoveUpFont.body())
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(lesson.priceFormatted)
                                .font(MoveUpFont.subtitle())
                                .fontWeight(.bold)
                                .foregroundColor(Color.moveUpPrimary)
                            
                            Text("per \(lesson.durationFormatted)")
                                .font(MoveUpFont.caption())
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, MoveUpSpacing.large)
                
                // Instructor Profile - Clickable - MARGINI SISTEMATI
                NavigationLink(destination: InstructorProfileView(instructor: instructor)) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.moveUpPrimary.opacity(0.1))
                            .frame(width: 56, height: 56)
                            .overlay(
                                Text("MT")
                                    .font(MoveUpFont.subtitle(18))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.moveUpPrimary)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Marco Trainer")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 6) {
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.moveUpGamification)
                                    
                                    Text("4.9")
                                        .font(MoveUpFont.caption())
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("•")
                                    .foregroundColor(.secondary)
                                    .font(MoveUpFont.caption())
                                
                                Text("120 lezioni")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, MoveUpSpacing.large)
                
                // Contact Button (Separated)
                Button(action: {
                    showContactInstructor = true
                }) {
                    HStack {
                        Image(systemName: "message")
                            .font(.system(size: 16, weight: .medium))
                        Text("Contatta Istruttore")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.moveUpSecondary.opacity(0.1))
                    .foregroundColor(Color.moveUpSecondary)
                    .cornerRadius(12)
                }
                .padding(.horizontal, MoveUpSpacing.large)
                
                // Description Section
                VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                    Text("Descrizione")
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(Color.moveUpPrimary)
                    
                    Text(lesson.description)
                        .font(MoveUpFont.body())
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal, MoveUpSpacing.large)
                
                // Location Section - Clickable for Navigation
                VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                    Text("Dove si svolge")
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(Color.moveUpPrimary)
                    
                    Button(action: {
                        openMapsApp(for: lesson.location)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.moveUpPrimary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.location.address)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text("\(lesson.location.city) - Tocca per navigare")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.moveUpPrimary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.moveUpPrimary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, MoveUpSpacing.large)
                
                Spacer(minLength: 100)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Indietro")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(Color.moveUpPrimary)
                }
            }
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                Spacer()
                
                Button("Prenota Ora") {
                    showBooking = true
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.moveUpPrimary)
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .semibold))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
            }
        }
        .sheet(isPresented: $showBooking) {
            BookingView(
                lesson: lesson,
                instructor: instructor,
                selectedDate: $selectedDate,
                selectedTimeSlot: $selectedTimeSlot
            )
        }
        .sheet(isPresented: $showContactInstructor) {
            ContactInstructorView(instructor: instructor)
        }
    }
    
    private func sportIcon(for sport: String) -> String {
        switch sport.lowercased() {
        case "calcio": return "soccerball"
        case "tennis": return "tennis.racket"
        case "padel": return "tennis.racket"
        case "pallavolo": return "volleyball"
        case "basket": return "basketball"
        case "nuoto": return "figure.pool.swim"
        case "yoga": return "figure.yoga"
        case "fitness": return "dumbbell"
        default: return "sportscourt"
        }
    }
    
    private func openMapsApp(for location: LocationData) {
        let encodedAddress = location.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedCity = location.city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let fullAddress = "\(encodedAddress), \(encodedCity)"
        
        // Try Apple Maps first
        if let appleMapsURL = URL(string: "http://maps.apple.com/?q=\(fullAddress)"),
           UIApplication.shared.canOpenURL(appleMapsURL) {
            UIApplication.shared.open(appleMapsURL)
        }
        // Fallback to Google Maps
        else if let googleMapsURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(fullAddress)"),
                UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL)
        }
        // Last resort: open in Safari
        else if let safariURL = URL(string: "https://maps.google.com/maps?q=\(fullAddress)") {
            UIApplication.shared.open(safariURL)
        }
    }
}

struct ContactInstructorView: View {
    let instructor: Instructor
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var isMessageSent = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.moveUpPrimary.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Text("MT")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.moveUpPrimary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Marco Trainer")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Istruttore certificato")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                // Quick Actions
                VStack(spacing: 12) {
                    Text("Azioni Rapide")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        ContactActionButton(
                            icon: "questionmark.circle",
                            title: "Ho una domanda sulla lezione",
                            message: "Ciao! Ho una domanda riguardo alla lezione. Potresti aiutarmi?"
                        ) { msg in
                            message = msg
                        }
                        
                        ContactActionButton(
                            icon: "calendar.circle",
                            title: "Vorrei cambiare orario",
                            message: "Ciao! Vorrei sapere se è possibile modificare l'orario della lezione."
                        ) { msg in
                            message = msg
                        }
                    }
                }
                
                // Custom Message
                VStack(alignment: .leading, spacing: 8) {
                    Text("Messaggio Personalizzato")
                        .font(.system(size: 16, weight: .medium))
                    
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                // Send Button
                Button(action: {
                    isMessageSent = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }) {
                    HStack {
                        if isMessageSent {
                            Image(systemName: "checkmark")
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                        
                        Text(isMessageSent ? "Messaggio Inviato!" : "Invia Messaggio")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isMessageSent ? Color.green : Color.moveUpPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(message.isEmpty || isMessageSent)
            }
            .padding(.horizontal, 20)
            .navigationTitle("Contatta Istruttore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ContactActionButton: View {
    let icon: String
    let title: String
    let message: String
    let onTap: (String) -> Void
    
    var body: some View {
        Button(action: {
            onTap(message)
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.moveUpPrimary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LessonDetailView(lesson: MockDataService.shared.mockLessons.first!)
        }
        .preferredColorScheme(.light)
    }
}