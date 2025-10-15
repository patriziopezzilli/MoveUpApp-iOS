import SwiftUI
import EventKit
import MapKit

struct InstructorTabView: View {
    @State private var selectedTab = 0
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                InstructorDashboardView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                InstructorLessonsView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Lezioni")
            }
            .tag(1)
            
            NavigationStack {
                InstructorBookingsView()
            }
            .tabItem {
                Image(systemName: "clock")
                Text("Prenotazioni")
            }
            .tag(2)
            
            NavigationStack {
                InstructorStatsView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Statistiche")
            }
            .tag(3)
            
            NavigationStack {
                InstructorWalletView()
            }
            .tabItem {
                Image(systemName: "eurosign.circle.fill")
                Text("Guadagni")
            }
            .tag(4)
            
            NavigationStack {
                InstructorSettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Impostazioni")
            }
            .tag(5)
        }
        .accentColor(Color.moveUpPrimary)
        .environmentObject(calendarManager)
    }
}

struct InstructorDashboardView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showNotifications = false
    @State private var showCreateLesson = false
    @State private var showAvailability = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: MoveUpSpacing.large) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Ciao, \(authViewModel.currentUser?.name.components(separatedBy: " ").first ?? "Istruttore")!")
                                    .font(MoveUpFont.title(24))
                                    .foregroundColor(Color.moveUpTextPrimary)
                                
                                Text("Ecco un riepilogo della tua attività")
                                    .font(MoveUpFont.body())
                                    .foregroundColor(Color.moveUpTextSecondary)
                            }
                            
                            Spacer()
                            
                            Button(action: { showNotifications = true }) {
                                Image(systemName: "bell")
                                    .font(.title2)
                                    .foregroundColor(Color.moveUpPrimary)
                            }
                        }
                        .padding(.horizontal, MoveUpSpacing.large)
                    }
                    
                    // Quick Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: MoveUpSpacing.medium) {
                        QuickStatCard(
                            title: "Prenotazioni Oggi",
                            value: "3",
                            icon: "calendar.badge.clock",
                            color: Color.moveUpSecondary
                        )
                        
                        QuickStatCard(
                            title: "Guadagni Mese",
                            value: "€1,240",
                            icon: "eurosign.circle.fill",
                            color: Color.moveUpAccent1
                        )
                        
                        QuickStatCard(
                            title: "Valutazione Media",
                            value: "4.8",
                            icon: "star.fill",
                            color: .moveUpGamification
                        )
                        
                        QuickStatCard(
                            title: "Lezioni Totali",
                            value: "156",
                            icon: "graduationcap.fill",
                            color: Color.moveUpAccent2
                        )
                    }
                    .padding(.horizontal, MoveUpSpacing.large)
                    
                    // Today's Schedule
                    VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
                        Text("Programma di Oggi")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpTextPrimary)
                            .padding(.horizontal, MoveUpSpacing.large)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: MoveUpSpacing.small) {
                                ForEach(sampleTodayBookings, id: \.id) { booking in
                                    TodayBookingCard(booking: booking)
                                }
                            }
                            .padding(.horizontal, MoveUpSpacing.large)
                        }
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                        Text("Azioni Rapide")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpTextPrimary)
                            .padding(.horizontal, MoveUpSpacing.large)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: MoveUpSpacing.medium) {
                            NavigationLink(destination: InstructorQRCodeView(
                                instructorId: authViewModel.currentUser?.id.uuidString ?? "INST-001",
                                instructorName: authViewModel.currentUser?.name ?? "Istruttore"
                            )) {
                                VStack(spacing: 12) {
                                    Image(systemName: "qrcode")
                                        .font(.system(size: 32))
                                        .foregroundColor(.black)
                                    
                                    Text("Il Tuo QR")
                                        .font(MoveUpFont.body())
                                        .foregroundColor(Color.moveUpTextPrimary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                )
                            }
                            
                            QuickActionCard(
                                title: "Nuova Lezione",
                                icon: "plus.circle.fill",
                                color: Color.moveUpSecondary
                            ) {
                                showCreateLesson = true
                            }
                            
                            QuickActionCard(
                                title: "Disponibilità",
                                icon: "calendar.badge.plus",
                                color: Color.moveUpPrimary
                            ) {
                                showAvailability = true
                            }
                        }
                        .padding(.horizontal, MoveUpSpacing.large)
                    }
                    
                    // Calendar Sync
                    CalendarSyncCard()
                        .padding(.horizontal, MoveUpSpacing.large)
                }
                .padding(.vertical, MoveUpSpacing.medium)
            }
            .background(Color.moveUpBackground)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showNotifications) {
            InstructorNotificationSettingsView()
        }
        .sheet(isPresented: $showCreateLesson) {
            CreateLessonView()
        }
        .sheet(isPresented: $showAvailability) {
            AvailabilityView()
        }
    }
    
    private let sampleTodayBookings = [
        TodayBooking(id: "1", studentName: "Mario Rossi", time: "09:00", sport: "Tennis", status: .confirmed),
        TodayBooking(id: "2", studentName: "Giulia Verdi", time: "11:00", sport: "Fitness", status: .pending),
        TodayBooking(id: "3", studentName: "Luca Bianchi", time: "15:30", sport: "Tennis", status: .confirmed)
    ]
}

struct TodayBooking {
    let id: String
    let studentName: String
    let time: String
    let sport: String
    let status: BookingStatus
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(MoveUpFont.title(24))
                    .fontWeight(.bold)
                    .foregroundColor(Color.moveUpTextPrimary)
                
                Text(title)
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

struct TodayBookingCard: View {
    let booking: TodayBooking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(booking.time)
                    .font(MoveUpFont.subtitle(16))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.moveUpTextPrimary)
                
                Spacer()
                
                Circle()
                    .fill(Color(booking.status.color))
                    .frame(width: 10, height: 10)
            }
            
            Text(booking.studentName)
                .font(MoveUpFont.body())
                .foregroundColor(Color.moveUpTextPrimary)
            
            Text(booking.sport)
                .font(MoveUpFont.caption())
                .foregroundColor(Color.moveUpTextSecondary)
        }
        .padding(16)
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Instructor Lessons View
struct InstructorLessonsView: View {
    @State private var showCreateLesson = false
    @State private var lessons: [Lesson] = MockDataService.shared.mockLessons
    
    var body: some View {
        ScrollView {
            VStack(spacing: MoveUpSpacing.large) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Le Mie Lezioni")
                            .font(MoveUpFont.title())
                            .foregroundColor(.moveUpPrimary)
                        
                        Text("\(lessons.count) lezioni attive")
                            .font(MoveUpFont.body())
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { showCreateLesson = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.moveUpPrimary)
                    }
                }
                .padding(.horizontal)
                
                // Lessons list
                ForEach(lessons) { lesson in
                    InstructorLessonCard(lesson: lesson)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color.moveUpBackground)
        .sheet(isPresented: $showCreateLesson) {
            CreateLessonView()
        }
    }
}

struct InstructorLessonCard: View {
    let lesson: Lesson
    @State private var showEdit = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(.primary)
                    
                    Text(lesson.sport.name)
                        .font(MoveUpFont.caption())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showEdit = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.moveUpSecondary)
                }
            }
            
            Divider()
            
            HStack {
                Label(lesson.priceFormatted, systemImage: "eurosign.circle")
                    .font(MoveUpFont.body())
                    .foregroundColor(.moveUpPrimary)
                
                Spacer()
                
                Label(lesson.durationFormatted, systemImage: "clock")
                    .font(MoveUpFont.body())
                    .foregroundColor(.secondary)
            }
            
            Text(lesson.description)
                .font(MoveUpFont.caption())
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        
        .sheet(isPresented: $showEdit) {
            EditLessonView(lesson: lesson)
        }
    }
}

// MARK: - Instructor Bookings View
struct InstructorBookingsView: View {
    @State private var selectedFilter: BookingFilterInstructor = .all
    @State private var bookings: [Booking] = Booking.sampleBookings
    
    var filteredBookings: [Booking] {
        switch selectedFilter {
        case .all: return bookings
        case .pending: return bookings.filter { $0.status == .pending }
        case .confirmed: return bookings.filter { $0.status == .confirmed }
        case .completed: return bookings.filter { $0.status == .completed }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Text("Prenotazioni")
                        .font(MoveUpFont.title())
                        .foregroundColor(.moveUpPrimary)
                    
                    Spacer()
                    
                    Text("\(filteredBookings.count)")
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(.moveUpSecondary)
                }
                
                // Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(BookingFilterInstructor.allCases, id: \.self) { filter in
                            FilterChipButton(
                                title: filter.displayName,
                                isSelected: selectedFilter == filter,
                                action: { selectedFilter = filter }
                            )
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            
            // Bookings list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredBookings) { booking in
                        InstructorBookingCard(booking: booking)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
        }
    }
}

enum BookingFilterInstructor: CaseIterable {
    case all, pending, confirmed, completed
    
    var displayName: String {
        switch self {
        case .all: return "Tutte"
        case .pending: return "Da Confermare"
        case .confirmed: return "Confermate"
        case .completed: return "Completate"
        }
    }
}

struct InstructorBookingCard: View {
    let booking: Booking
    @State private var showStudentInfo = false
    @State private var showConfirmation = false
    @State private var showRejectConfirmation = false
    @State private var showCalendarSuccess = false
    @State private var calendarError: String?
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.moveUpPrimary.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("MR")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(.moveUpPrimary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mario Rossi") // Mock - in produzione dal booking
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(.primary)
                    
                    Text(booking.lessonDate.formatted(.dateTime.day().month().hour().minute()))
                        .font(MoveUpFont.caption())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(booking.formattedAmount)
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(.moveUpPrimary)
                    
                    StatusBadge(status: booking.status)
                }
            }
            
            if booking.status == .pending {
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: {
                        showRejectConfirmation = true
                    }) {
                        Text("Rifiuta")
                            .font(MoveUpFont.body())
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showConfirmation = true
                    }) {
                        Text("Conferma")
                            .font(MoveUpFont.body())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.moveUpPrimary)
                            .cornerRadius(8)
                    }
                }
            } else if booking.status == .confirmed && booking.lessonDate > Date() {
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: { showStudentInfo = true }) {
                        HStack {
                            Image(systemName: "person.circle")
                            Text("Info Studente")
                        }
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.moveUpSecondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: addToCalendar) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Calendario")
                        }
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.moveUpPrimary.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        
        .sheet(isPresented: $showStudentInfo) {
            StudentInfoView()
        }
        .alert("Conferma Prenotazione", isPresented: $showConfirmation) {
            Button("Annulla", role: .cancel) { }
            Button("Conferma") {
                // Conferma prenotazione - aggiornare stato
            }
        } message: {
            Text("Vuoi confermare questa prenotazione?")
        }
        .alert("Rifiuta Prenotazione", isPresented: $showRejectConfirmation) {
            Button("Annulla", role: .cancel) { }
            Button("Rifiuta", role: .destructive) {
                // Rifiuta prenotazione - aggiornare stato
            }
        } message: {
            Text("Sei sicuro di voler rifiutare questa prenotazione?")
        }
        .alert("Aggiunto al Calendario!", isPresented: $showCalendarSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("La lezione è stata aggiunta al tuo calendario.")
        }
        .alert("Errore", isPresented: .constant(calendarError != nil)) {
            Button("OK", role: .cancel) { calendarError = nil }
        } message: {
            Text(calendarError ?? "")
        }
    }
    
    private func addToCalendar() {
        Task {
            do {
                // Richiedi permesso se necessario
                if calendarManager.authorizationStatus == .notDetermined {
                    let granted = try await calendarManager.requestAccess()
                    if !granted {
                        await MainActor.run {
                            calendarError = "Accesso al calendario negato"
                        }
                        return
                    }
                }
                
                // Calcola la data di fine (1 ora dopo l'inizio - da customizzare in base alla durata reale)
                let endDate = booking.lessonDate.addingTimeInterval(3600)
                
                // Crea l'evento
                _ = try calendarManager.createEvent(
                    title: "Lezione MoveUp - Mario Rossi",
                    startDate: booking.lessonDate,
                    endDate: endDate,
                    location: "Da definire",
                    notes: "Prenotazione confermata tramite MoveUp\nImporto: \(booking.formattedAmount)"
                )
                
                await MainActor.run {
                    showCalendarSuccess = true
                }
            } catch {
                await MainActor.run {
                    calendarError = error.localizedDescription
                }
            }
        }
    }
}

struct FilterChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MoveUpFont.body())
                .foregroundColor(isSelected ? .white : .moveUpPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.moveUpPrimary : Color.moveUpPrimary.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

// MARK: - Instructor Stats View
struct InstructorStatsView: View {
    @State private var selectedPeriod: StatsPeriod = .month
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Text("Statistiche")
                        .font(MoveUpFont.title())
                        .foregroundColor(.moveUpPrimary)
                    
                    // Period selector
                    Picker("Periodo", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                
                // Earnings Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Guadagni")
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(.moveUpPrimary)
                    
                    HStack(spacing: 12) {
                        EarningsCard(
                            title: "Totale",
                            amount: "€1,240",
                            icon: "eurosign.circle.fill",
                            color: .moveUpPrimary
                        )
                        
                        EarningsCard(
                            title: "Medio/Lezione",
                            amount: "€45",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .moveUpAccent1
                        )
                    }
                }
                .padding(.horizontal)
                
                // Performance Metrics
                VStack(alignment: .leading, spacing: 16) {
                    Text("Performance")
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(.moveUpPrimary)
                    
                    VStack(spacing: 12) {
                        MetricRow(
                            title: "Lezioni Completate",
                            value: "28",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        MetricRow(
                            title: "Ore Insegnate",
                            value: "42",
                            icon: "clock.fill",
                            color: .moveUpSecondary
                        )
                        
                        MetricRow(
                            title: "Nuovi Studenti",
                            value: "12",
                            icon: "person.2.fill",
                            color: .moveUpAccent1
                        )
                        
                        MetricRow(
                            title: "Tasso Completamento",
                            value: "96%",
                            icon: "chart.pie.fill",
                            color: .moveUpGamification
                        )
                    }
                }
                .padding(.horizontal)
                
                // Reviews Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recensioni")
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(.moveUpPrimary)
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("4.8")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.moveUpPrimary)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < 4 ? "star.fill" : "star.leadinghalf.filled")
                                        .foregroundColor(.moveUpGamification)
                                }
                            }
                            
                            Text("156 recensioni")
                                .font(MoveUpFont.caption())
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            RatingBar(stars: 5, count: 120)
                            RatingBar(stars: 4, count: 28)
                            RatingBar(stars: 3, count: 6)
                            RatingBar(stars: 2, count: 2)
                            RatingBar(stars: 1, count: 0)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                // Top Students
                VStack(alignment: .leading, spacing: 16) {
                    Text("Top Studenti")
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(.moveUpPrimary)
                    
                    VStack(spacing: 12) {
                        TopStudentRow(name: "Mario Rossi", lessons: 12, badge: "🥇")
                        TopStudentRow(name: "Giulia Verdi", lessons: 10, badge: "🥈")
                        TopStudentRow(name: "Luca Bianchi", lessons: 8, badge: "🥉")
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.moveUpBackground)
    }
}

enum StatsPeriod: CaseIterable {
    case week, month, year
    
    var displayName: String {
        switch self {
        case .week: return "Settimana"
        case .month: return "Mese"
        case .year: return "Anno"
        }
    }
}

struct EarningsCard: View {
    let title: String
    let amount: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(amount)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(MoveUpFont.caption())
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(MoveUpFont.body())
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(MoveUpFont.subtitle())
                .foregroundColor(.moveUpPrimary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

struct RatingBar: View {
    let stars: Int
    let count: Int
    let maxCount = 120
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(stars)")
                .font(MoveUpFont.caption())
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color.moveUpGamification)
                        .frame(width: geometry.size.width * CGFloat(count) / CGFloat(maxCount), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            Text("\(count)")
                .font(MoveUpFont.caption())
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct TopStudentRow: View {
    let name: String
    let lessons: Int
    let badge: String
    
    var body: some View {
        HStack {
            Text(badge)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(MoveUpFont.body())
                    .foregroundColor(.primary)
                
                Text("\(lessons) lezioni")
                    .font(MoveUpFont.caption())
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Instructor Settings View
struct InstructorSettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showEditProfile = false
    @State private var showAvailability = false
    @State private var showPaymentSettings = false
    @State private var showNotifications = false
    @State private var showPricing = false
    @State private var showServiceZones = false
    @State private var showEarningsHistory = false
    @State private var showSupport = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.moveUpPrimary)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(authViewModel.currentUser?.name.prefix(2).uppercased() ?? "IN")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(spacing: 8) {
                        Text(authViewModel.currentUser?.name ?? "Istruttore")
                            .font(MoveUpFont.title(20))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.moveUpGamification)
                                Text("4.8")
                                    .font(MoveUpFont.body())
                            }
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("156 lezioni")
                                .font(MoveUpFont.body())
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: { showEditProfile = true }) {
                        Text("Modifica Profilo")
                            .font(MoveUpFont.body())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.moveUpPrimary)
                            .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.white)
                
                
                // Settings Sections
                VStack(spacing: 16) {
                    SettingsSection(title: "Profilo e Lezioni") {
                        InstructorSettingsRow(
                            icon: "person.circle.fill",
                            title: "Informazioni Personali",
                            subtitle: "Nome, email, contatti"
                        ) {
                            showEditProfile = true
                        }
                        
                        InstructorSettingsRow(
                            icon: "calendar.badge.clock",
                            title: "Disponibilità",
                            subtitle: "Gestisci i tuoi orari"
                        ) {
                            showAvailability = true
                        }
                        
                        InstructorSettingsRow(
                            icon: "dollarsign.circle.fill",
                            title: "Tariffe",
                            subtitle: "Gestisci i prezzi delle lezioni"
                        ) {
                            showPricing = true
                        }
                        
                        InstructorSettingsRow(
                            icon: "mappin.circle.fill",
                            title: "Zone di Servizio",
                            subtitle: "Dove offri le tue lezioni"
                        ) {
                            showServiceZones = true
                        }
                    }
                    
                    SettingsSection(title: "Pagamenti") {
                        InstructorSettingsRow(
                            icon: "creditcard.circle.fill",
                            title: "Metodi di Pagamento",
                            subtitle: "Gestisci come ricevi i pagamenti"
                        ) {
                            showPaymentSettings = true
                        }
                        
                        InstructorSettingsRow(
                            icon: "chart.line.uptrend.xyaxis.circle.fill",
                            title: "Storico Guadagni",
                            subtitle: "Vedi i tuoi guadagni"
                        ) {
                            showEarningsHistory = true
                        }
                    }
                    
                    SettingsSection(title: "Preferenze") {
                        InstructorSettingsRow(
                            icon: "bell.circle.fill",
                            title: "Notifiche",
                            subtitle: "Gestisci le notifiche"
                        ) {
                            showNotifications = true
                        }
                        
                        InstructorSettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "Aiuto e Supporto",
                            subtitle: "FAQ e assistenza"
                        ) {
                            showSupport = true
                        }
                    }
                    
                    // Logout button
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Esci dall'Account")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.moveUpBackground)
        .sheet(isPresented: $showEditProfile) {
            EditInstructorProfileView()
        }
        .sheet(isPresented: $showAvailability) {
            AvailabilityView()
        }
        .sheet(isPresented: $showPaymentSettings) {
            PaymentSettingsView()
        }
        .sheet(isPresented: $showNotifications) {
            InstructorNotificationSettingsView()
        }
        .sheet(isPresented: $showPricing) {
            PricingView()
        }
        .sheet(isPresented: $showServiceZones) {
            ServiceZonesView()
        }
        .sheet(isPresented: $showEarningsHistory) {
            EarningsHistoryView()
        }
        .sheet(isPresented: $showSupport) {
            InstructorSupportView()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(MoveUpFont.subtitle())
                .foregroundColor(.moveUpPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                content
            }
        }
    }
}

struct InstructorSettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.moveUpPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.moveUpPrimary.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(MoveUpFont.body())
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(MoveUpFont.caption())
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Create Lesson View
struct CreateLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedSport = Sport.sampleSports[0]
    @State private var price = ""
    @State private var duration = "60"
    @State private var skillLevel: SkillLevel = .beginner
    @State private var equipment: [String] = []
    @State private var newEquipment = ""
    @State private var showSuccess = false
    
    let durationOptions = ["30", "60", "90", "120"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Form Content
                    VStack(spacing: 24) {
                        // Info Card
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.moveUpAccent1)
                                .font(.title3)
                            
                            Text("Completa tutti i campi per creare una lezione perfetta")
                                .font(MoveUpFont.caption())
                                .foregroundColor(.moveUpTextSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.moveUpAccent1.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Titolo
                        ModernTextField(
                            title: "Titolo Lezione",
                            placeholder: "Es. Lezione di Tennis Base",
                            text: $title,
                            icon: "text.cursor"
                        )
                        
                        // Sport
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Sport", systemImage: "figure.run")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.moveUpTextPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Sport.sampleSports) { sport in
                                        SportChip(sport: sport, isSelected: selectedSport.id == sport.id) {
                                            selectedSport = sport
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Descrizione
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Descrizione", systemImage: "doc.text")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.moveUpTextPrimary)
                            
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(description.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Prezzo e Durata
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Prezzo", systemImage: "eurosign.circle")
                                    .font(MoveUpFont.body())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.moveUpTextPrimary)
                                
                                HStack {
                                    Text("€")
                                        .font(MoveUpFont.body())
                                        .foregroundColor(.moveUpTextSecondary)
                                    TextField("45", text: $price)
                                        .keyboardType(.decimalPad)
                                        .font(MoveUpFont.body())
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(price.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Durata", systemImage: "clock")
                                    .font(MoveUpFont.body())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.moveUpTextPrimary)
                                
                                Picker("Durata", selection: $duration) {
                                    ForEach(durationOptions, id: \.self) { option in
                                        Text("\(option) min").tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Fee Breakdown (real-time preview)
                        if let priceValue = Double(price), priceValue > 0 {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.moveUpPrimary)
                                    Text("Quanto riceverai per questa lezione:")
                                        .font(MoveUpFont.caption())
                                        .foregroundColor(.moveUpTextSecondary)
                                    Spacer()
                                }
                                
                                CompactFeeBreakdownView(grossAmount: priceValue)
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        // Livello
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Livello Richiesto", systemImage: "chart.bar.fill")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.moveUpTextPrimary)
                            
                            Picker("Livello", selection: $skillLevel) {
                                Text("Principiante").tag(SkillLevel.beginner)
                                Text("Intermedio").tag(SkillLevel.intermediate)
                                Text("Avanzato").tag(SkillLevel.advanced)
                                Text("Pro").tag(SkillLevel.professional)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Attrezzatura
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Attrezzatura", systemImage: "bag.fill")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.moveUpTextPrimary)
                            
                            HStack(spacing: 12) {
                                TextField("Aggiungi attrezzatura", text: $newEquipment)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                
                                Button(action: {
                                    if !newEquipment.isEmpty {
                                        equipment.append(newEquipment)
                                        newEquipment = ""
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.moveUpPrimary)
                                }
                            }
                            
                            if !equipment.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(equipment, id: \.self) { item in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.moveUpAccent1)
                                            Text(item)
                                                .font(MoveUpFont.body())
                                            Spacer()
                                            Button(action: {
                                                equipment.removeAll { $0 == item }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Create Button
                        Button(action: {
                            showSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Crea Lezione")
                            }
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.moveUpPrimary : Color.gray)
                            .cornerRadius(12)
                            
                        }
                        .disabled(!isFormValid)
                    }
                    .padding()
                }
                .padding(.top)
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Nuova Lezione")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.3), value: price)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Indietro")
                        }
                        .foregroundColor(.moveUpPrimary)
                    }
                }
            }
            .alert("Lezione Creata!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("La tua lezione è stata creata con successo!")
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && !price.isEmpty
    }
}

// MARK: - Modern Text Field
struct ModernTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(MoveUpFont.body())
                .fontWeight(.semibold)
                .foregroundColor(.moveUpTextPrimary)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(text.isEmpty ? Color.gray.opacity(0.2) : Color.moveUpPrimary.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Sport Chip
struct SportChip: View {
    let sport: Sport
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: sportIcon(for: sport))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .moveUpPrimary)
                
                Text(sport.name.capitalized)
                    .font(MoveUpFont.caption())
                    .foregroundColor(isSelected ? .white : .moveUpTextPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isSelected ? Color.moveUpPrimary : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
            
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

// MARK: - Edit Lesson View
struct EditLessonView: View {
    let lesson: Lesson
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var duration = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.moveUpSecondary)
                        
                        Text("Modifica Lezione")
                            .font(MoveUpFont.title())
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Titolo")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                            
                            TextField(lesson.title, text: $title)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descrizione")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                            
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Prezzo (€)")
                                    .font(MoveUpFont.body())
                                    .fontWeight(.semibold)
                                
                                TextField(String(format: "%.0f", lesson.price), text: $price)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Durata (min)")
                                    .font(MoveUpFont.body())
                                    .fontWeight(.semibold)
                                
                                TextField(String(lesson.duration / 60), text: $duration)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Fee Breakdown (real-time preview)
                        if let priceValue = Double(price), priceValue > 0 {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.moveUpPrimary)
                                    Text("Quanto riceverai per questa lezione:")
                                        .font(MoveUpFont.caption())
                                        .foregroundColor(.moveUpTextSecondary)
                                    Spacer()
                                }
                                
                                CompactFeeBreakdownView(grossAmount: priceValue)
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        // Stato pubblicazione
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Stato Pubblicazione")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 12) {
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "eye.fill")
                                        Text("Pubblica")
                                    }
                                    .font(MoveUpFont.body())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {}) {
                                    HStack {
                                        Image(systemName: "eye.slash.fill")
                                        Text("Nascondi")
                                    }
                                    .font(MoveUpFont.body())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismiss()
                            }
                        }) {
                            Text("Salva Modifiche")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.moveUpPrimary)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Elimina lezione
                        }) {
                            Text("Elimina Lezione")
                                .font(MoveUpFont.body())
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Modifica Lezione")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.3), value: price)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
            .alert("Modifiche Salvate!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Le modifiche sono state salvate con successo!")
            }
        }
        .onAppear {
            title = lesson.title
            description = lesson.description
            price = String(format: "%.0f", lesson.price)
            duration = String(lesson.duration / 60)
        }
    }
}

// MARK: - Student Info View
struct StudentInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Student Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.moveUpPrimary.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("MR")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.moveUpPrimary)
                            )
                        
                        VStack(spacing: 8) {
                            Text("Mario Rossi")
                                .font(MoveUpFont.title())
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.moveUpGamification)
                                    Text("4.9")
                                        .font(MoveUpFont.body())
                                }
                                
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                Text("12 lezioni completate")
                                    .font(MoveUpFont.body())
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Contact Info
                    VStack(spacing: 12) {
                        ContactInfoRow(
                            icon: "envelope.fill",
                            title: "Email",
                            value: "mario.rossi@email.com",
                            action: {
                                if let url = URL(string: "mailto:mario.rossi@email.com") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                        
                        ContactInfoRow(
                            icon: "phone.fill",
                            title: "Telefono",
                            value: "+39 333 111 2222",
                            action: {
                                if let url = URL(string: "tel://+393331112222") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                    
                    // Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Statistiche")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(.moveUpPrimary)
                        
                        HStack(spacing: 12) {
                            StudentStatCard(
                                title: "Lezioni",
                                value: "12",
                                icon: "graduationcap.fill",
                                color: .moveUpPrimary
                            )
                            
                            StudentStatCard(
                                title: "Completate",
                                value: "11",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                            
                            StudentStatCard(
                                title: "Cancellate",
                                value: "1",
                                icon: "xmark.circle.fill",
                                color: .red
                            )
                        }
                    }
                    
                    // Recent Lessons
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lezioni Recenti")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(.moveUpPrimary)
                        
                        VStack(spacing: 12) {
                            RecentLessonRow(
                                title: "Lezione di Tennis",
                                date: "15 Ott 2025",
                                status: "Completata"
                            )
                            
                            RecentLessonRow(
                                title: "Lezione di Tennis",
                                date: "8 Ott 2025",
                                status: "Completata"
                            )
                            
                            RecentLessonRow(
                                title: "Lezione di Tennis",
                                date: "1 Ott 2025",
                                status: "Completata"
                            )
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Note Personali")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(.moveUpPrimary)
                        
                        Text("Studente motivato, ottimi progressi nel dritto. Lavorare sul rovescio.")
                            .font(MoveUpFont.body())
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Info Studente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
        }
    }
}

struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.moveUpPrimary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(MoveUpFont.caption())
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(MoveUpFont.body())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.moveUpPrimary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
        }
    }
}

struct StudentStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(MoveUpFont.caption())
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        
    }
}

struct RecentLessonRow: View {
    let title: String
    let date: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MoveUpFont.body())
                    .foregroundColor(.primary)
                
                Text(date)
                    .font(MoveUpFont.caption())
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(status)
                .font(MoveUpFont.caption())
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        
    }
}

// MARK: - Edit Instructor Profile View
struct EditInstructorProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = "Marco Santini"
    @State private var email = "instructor@moveup.com"
    @State private var phone = "+39 335 567 8901"
    @State private var bio = "Istruttore di tennis con 10 anni di esperienza"
    @State private var certifications = "CONI, FIT"
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.moveUpPrimary)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("MS")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        Button("Cambia Foto") {
                            // Change photo
                        }
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpPrimary)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        FormField(title: "Nome Completo", text: $name)
                        FormField(title: "Email", text: $email, keyboardType: .emailAddress)
                        FormField(title: "Telefono", text: $phone, keyboardType: .phonePad)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                            
                            TextEditor(text: $bio)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        FormField(title: "Certificazioni", text: $certifications)
                    }
                    
                    // Save Button
                    Button(action: {
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }) {
                        Text("Salva Modifiche")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.moveUpPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Modifica Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
            .alert("Profilo Aggiornato!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Il tuo profilo è stato aggiornato con successo!")
            }
        }
    }
}

struct FormField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(MoveUpFont.body())
                .fontWeight(.semibold)
            
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

// MARK: - Availability View
struct AvailabilityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var slotDuration: SlotDuration = .halfHour
    @State private var halfHourSlots: [InstructorTimeSlot] = [
        InstructorTimeSlot(time: "09:00 - 09:30", isAvailable: true),
        InstructorTimeSlot(time: "09:30 - 10:00", isAvailable: true),
        InstructorTimeSlot(time: "10:00 - 10:30", isAvailable: true),
        InstructorTimeSlot(time: "10:30 - 11:00", isAvailable: true),
        InstructorTimeSlot(time: "11:00 - 11:30", isAvailable: false),
        InstructorTimeSlot(time: "11:30 - 12:00", isAvailable: false),
        InstructorTimeSlot(time: "14:00 - 14:30", isAvailable: true),
        InstructorTimeSlot(time: "14:30 - 15:00", isAvailable: true),
        InstructorTimeSlot(time: "15:00 - 15:30", isAvailable: false),
        InstructorTimeSlot(time: "15:30 - 16:00", isAvailable: false),
        InstructorTimeSlot(time: "16:00 - 16:30", isAvailable: true),
        InstructorTimeSlot(time: "16:30 - 17:00", isAvailable: true),
        InstructorTimeSlot(time: "17:00 - 17:30", isAvailable: true),
        InstructorTimeSlot(time: "17:30 - 18:00", isAvailable: true),
        InstructorTimeSlot(time: "18:00 - 18:30", isAvailable: false),
        InstructorTimeSlot(time: "18:30 - 19:00", isAvailable: false)
    ]
    @State private var oneHourSlots: [InstructorTimeSlot] = [
        InstructorTimeSlot(time: "09:00 - 10:00", isAvailable: true),
        InstructorTimeSlot(time: "10:00 - 11:00", isAvailable: true),
        InstructorTimeSlot(time: "11:00 - 12:00", isAvailable: false),
        InstructorTimeSlot(time: "14:00 - 15:00", isAvailable: true),
        InstructorTimeSlot(time: "15:00 - 16:00", isAvailable: false),
        InstructorTimeSlot(time: "16:00 - 17:00", isAvailable: true),
        InstructorTimeSlot(time: "17:00 - 18:00", isAvailable: true),
        InstructorTimeSlot(time: "18:00 - 19:00", isAvailable: false)
    ]
    @State private var showSuccess = false
    
    enum SlotDuration: String, CaseIterable {
        case halfHour = "30 min"
        case oneHour = "1 ora"
    }
    
    var currentSlots: Binding<[InstructorTimeSlot]> {
        slotDuration == .halfHour ? $halfHourSlots : $oneHourSlots
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar
                DatePicker(
                    "Seleziona Data",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color.white)
                
                Divider()
                
                // Duration Picker
                Picker("Durata Slot", selection: $slotDuration) {
                    ForEach(SlotDuration.allCases, id: \.self) { duration in
                        Text(duration.rawValue).tag(duration)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(.systemGray6))
                
                // Time Slots
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(currentSlots.wrappedValue.indices, id: \.self) { index in
                            HStack {
                                Text(currentSlots.wrappedValue[index].time)
                                    .font(MoveUpFont.body())
                                    .foregroundColor(.moveUpTextPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: currentSlots[index].isAvailable)
                                    .labelsHidden()
                                    .tint(.moveUpPrimary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(currentSlots.wrappedValue[index].isAvailable ? Color.moveUpAccent1.opacity(0.1) : Color(.systemGray6))
                            )
                        }
                    }
                    .padding()
                }
                
                // Save Button
                Button(action: {
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }) {
                    Text("Salva Disponibilità")
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.moveUpPrimary)
                        .cornerRadius(12)
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Gestisci Disponibilità")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
            .alert("Disponibilità Aggiornata!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("La tua disponibilità è stata salvata con successo!")
            }
        }
    }
}

struct InstructorTimeSlot: Identifiable {
    let id = UUID()
    let time: String
    var isAvailable: Bool
}

// MARK: - Payment Settings View (Nome + IBAN - Stripe trasparente)
struct PaymentSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = "Marco Santini"
    @State private var iban = "IT60 X054 2811 1010 0000 0123 456"
    @State private var isVerified = true
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Status Card
                    VStack(spacing: 16) {
                        Image(systemName: isVerified ? "checkmark.shield.fill" : "clock.fill")
                            .font(.system(size: 50))
                            .foregroundColor(isVerified ? .green : .orange)
                        
                        Text(isVerified ? "Account Verificato" : "Verifica in Corso")
                            .font(MoveUpFont.title())
                            .fontWeight(.bold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        Text(isVerified ? "I tuoi pagamenti vengono elaborati automaticamente" : "La verifica dell'IBAN richiede 1-2 giorni lavorativi")
                            .font(MoveUpFont.body())
                            .foregroundColor(Color.moveUpTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isVerified ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Account Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dati Bancari")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        VStack(spacing: 12) {
                            // Nome Completo
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nome Intestatario")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(Color.moveUpTextSecondary)
                                
                                TextField("Nome e Cognome", text: $fullName)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                            }
                            
                            // IBAN
                            VStack(alignment: .leading, spacing: 8) {
                                Text("IBAN")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(Color.moveUpTextSecondary)
                                
                                TextField("IT60 X054 2811 1010 0000 0123 456", text: $iban)
                                    .keyboardType(.default)
                                    .autocapitalization(.allCharacters)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    
                    // Info Box
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color.moveUpAccent1)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pagamenti Automatici")
                                .font(MoveUpFont.caption())
                                .fontWeight(.semibold)
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            Text("I guadagni vengono accreditati automaticamente ogni 2-3 giorni lavorativi")
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.moveUpAccent1.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Save Button
                    Button(action: {
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }) {
                        Text("Salva Dati Bancari")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.moveUpPrimary : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Metodo di Pagamento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
            .alert("Dati Aggiornati!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("I tuoi dati bancari sono stati aggiornati con successo!")
            }
        }
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty && !iban.isEmpty && iban.count >= 15
    }
}

struct InstructorFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.moveUpPrimary)
                .frame(width: 30)
            
            Text(text)
                .font(MoveUpFont.body())
                .foregroundColor(.moveUpTextPrimary)
        }
    }
}

// MARK: - Notification Settings View
struct InstructorNotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bookingNotifications = true
    @State private var messageNotifications = true
    @State private var reviewNotifications = true
    @State private var reminderNotifications = true
    @State private var promotionalNotifications = false
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Notification Types
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tipi di Notifiche")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                        
                        NotificationToggle(
                            title: "Nuove Prenotazioni",
                            description: "Ricevi notifiche per nuove richieste di prenotazione",
                            isOn: $bookingNotifications
                        )
                        
                        NotificationToggle(
                            title: "Messaggi",
                            description: "Ricevi notifiche per nuovi messaggi dagli studenti",
                            isOn: $messageNotifications
                        )
                        
                        NotificationToggle(
                            title: "Recensioni",
                            description: "Ricevi notifiche quando ricevi una nuova recensione",
                            isOn: $reviewNotifications
                        )
                        
                        NotificationToggle(
                            title: "Promemoria Lezioni",
                            description: "Ricevi promemoria 1 ora prima di ogni lezione",
                            isOn: $reminderNotifications
                        )
                        
                        NotificationToggle(
                            title: "Offerte e Promozioni",
                            description: "Ricevi notifiche su nuove funzionalità e offerte",
                            isOn: $promotionalNotifications
                        )
                    }
                    
                    Divider()
                    
                    // Notification Channels
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Canali di Notifica")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                        
                        NotificationToggle(
                            title: "Notifiche Email",
                            description: "Ricevi notifiche via email",
                            isOn: $emailNotifications
                        )
                        
                        NotificationToggle(
                            title: "Notifiche Push",
                            description: "Ricevi notifiche push sul tuo dispositivo",
                            isOn: $pushNotifications
                        )
                    }
                    
                    // Save Button
                    Button(action: {
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }) {
                        Text("Salva Preferenze")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.moveUpPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Notifiche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
            .alert("Preferenze Salvate!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Le tue preferenze di notifica sono state aggiornate!")
            }
        }
    }
}

struct NotificationToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(MoveUpFont.body())
                        .foregroundColor(.moveUpTextPrimary)
                    
                    Text(description)
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
}

struct InstructorTabView_Previews: PreviewProvider {
    static var previews: some View {
        InstructorTabView()
            .environmentObject(AuthenticationViewModel())
    }
}

// MARK: - Pricing View
struct PricingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var halfHourPrice = "25"
    @State private var oneHourPrice = "45"
    @State private var twoHourPrice = "80"
    @State private var groupDiscount = "15"
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Tariffe Base
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tariffe per Durata")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                        
                        VStack(spacing: 20) {
                            VStack(spacing: 12) {
                                PriceField(label: "30 minuti", price: $halfHourPrice)
                                
                                if let price = Double(halfHourPrice), price > 0 {
                                    CompactFeeBreakdownView(grossAmount: price)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                            
                            Divider()
                            
                            VStack(spacing: 12) {
                                PriceField(label: "1 ora", price: $oneHourPrice)
                                
                                if let price = Double(oneHourPrice), price > 0 {
                                    CompactFeeBreakdownView(grossAmount: price)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                            
                            Divider()
                            
                            VStack(spacing: 12) {
                                PriceField(label: "2 ore", price: $twoHourPrice)
                                
                                if let price = Double(twoHourPrice), price > 0 {
                                    CompactFeeBreakdownView(grossAmount: price)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Sconti
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sconti e Promozioni")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("Sconto lezioni di gruppo")
                                .font(MoveUpFont.body())
                            Spacer()
                            HStack(spacing: 4) {
                                TextField("15", text: $groupDiscount)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 50)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                Text("%")
                                    .font(MoveUpFont.body())
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Info
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.moveUpAccent1)
                        Text("I prezzi sono indicativi e possono variare in base alla distanza e al tipo di lezione")
                            .font(MoveUpFont.caption())
                            .foregroundColor(.moveUpTextSecondary)
                    }
                    .padding()
                    .background(Color.moveUpAccent1.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Save Button
                    Button(action: {
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }) {
                        Text("Salva Tariffe")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.moveUpPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Gestisci Tariffe")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.3), value: halfHourPrice)
            .animation(.easeInOut(duration: 0.3), value: oneHourPrice)
            .animation(.easeInOut(duration: 0.3), value: twoHourPrice)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
            .alert("Tariffe Aggiornate!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

struct PriceField: View {
    let label: String
    @Binding var price: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(MoveUpFont.body())
            Spacer()
            HStack(spacing: 4) {
                Text("€")
                    .font(MoveUpFont.body())
                TextField("0", text: $price)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Service Zones View
// MARK: - Service Zones View (GPS-based)
struct ServiceZonesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var zones: [ServiceZone] = ServiceZone.sampleZones
    @State private var showAddZone = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Info Card
                    HStack(spacing: 12) {
                        Image(systemName: "location.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color.moveUpPrimary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Zone di Servizio GPS")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            Text("Definisci le aree geografiche dove offri le tue lezioni")
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.moveUpPrimary.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Current Zones List
                    if !zones.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Zone Attive (\(zones.count))")
                                .font(MoveUpFont.subtitle())
                                .fontWeight(.bold)
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            ForEach(zones) { zone in
                                ServiceZoneCard(zone: zone) {
                                    // Toggle zone
                                    if let index = zones.firstIndex(where: { $0.id == zone.id }) {
                                        zones[index].isActive.toggle()
                                    }
                                } onDelete: {
                                    zones.removeAll { $0.id == zone.id }
                                }
                            }
                        }
                    } else {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "map.circle")
                                .font(.system(size: 60))
                                .foregroundColor(Color.moveUpTextSecondary.opacity(0.5))
                            
                            Text("Nessuna Zona Configurata")
                                .font(MoveUpFont.subtitle())
                                .foregroundColor(Color.moveUpTextSecondary)
                            
                            Text("Aggiungi la tua prima zona di servizio per iniziare a ricevere richieste")
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 40)
                    }
                    
                    // Add Zone Button
                    Button(action: {
                        showAddZone = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Aggiungi Nuova Zona")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.moveUpPrimary)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Zone di Servizio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
            .sheet(isPresented: $showAddZone) {
                AddServiceZoneView(locationManager: locationManager) { newZone in
                    zones.append(newZone)
                    showSuccess = true
                }
            }
            .alert("Zona Salvata!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("La tua zona di servizio è stata aggiunta con successo!")
            }
        }
    }
}

// MARK: - Service Zone Card
struct ServiceZoneCard: View {
    let zone: ServiceZone
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(zone.isActive ? Color.moveUpPrimary : Color.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(zone.name)
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    Text("Raggio: \(String(format: "%.1f", zone.radiusInKilometers)) km")
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextSecondary)
                }
                
                Spacer()
                
                Toggle("", isOn: .constant(zone.isActive))
                    .labelsHidden()
                    .tint(Color.moveUpPrimary)
                    .onChange(of: zone.isActive) { _ in
                        onToggle()
                    }
            }
            
            // Coordinates
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(Color.moveUpTextSecondary)
                
                Text(String(format: "%.4f, %.4f", zone.center.latitude, zone.center.longitude))
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
            }
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    // Mostra su mappa
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                        Text("Mappa")
                    }
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.moveUpPrimary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: onDelete) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Elimina")
                    }
                    .font(MoveUpFont.caption())
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(zone.isActive ? Color.moveUpPrimary.opacity(0.3) : Color.black.opacity(0.08), lineWidth: zone.isActive ? 2 : 1)
        )
    }
}

// MARK: - Add Service Zone View
struct AddServiceZoneView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locationManager: LocationManager
    
    @State private var zoneName = ""
    @State private var radius: Double = 15.0 // km
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.4642, longitude: 9.1900),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    let onSave: (ServiceZone) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Zone Name
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nome Zona")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        TextField("es. Milano Centro", text: $zoneName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }
                    
                    // Map
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Centro Zona")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        ZStack {
                            Map(coordinateRegion: $region, annotationItems: selectedCoordinate != nil ? [MapAnnotationItem(coordinate: selectedCoordinate!)] : []) { item in
                                MapAnnotation(coordinate: item.coordinate) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.moveUpPrimary.opacity(0.2))
                                            .frame(width: radiusInMapPoints, height: radiusInMapPoints)
                                        
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.title)
                                            .foregroundColor(Color.moveUpPrimary)
                                    }
                                }
                            }
                            .frame(height: 300)
                            .cornerRadius(12)
                            .onTapGesture { location in
                                // Calculate coordinate from tap (approximation)
                                let frame = UIScreen.main.bounds
                                let x = location.x / frame.width
                                let y = location.y / 300
                                
                                let lat = region.center.latitude + (y - 0.5) * region.span.latitudeDelta
                                let lon = region.center.longitude + (x - 0.5) * region.span.longitudeDelta
                                
                                selectedCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            }
                            
                            if selectedCoordinate == nil {
                                VStack {
                                    Image(systemName: "hand.tap.fill")
                                        .font(.title)
                                    Text("Tap per scegliere la posizione")
                                        .font(MoveUpFont.caption())
                                }
                                .foregroundColor(Color.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Use Current Location
                        Button(action: {
                            if let location = locationManager.location {
                                selectedCoordinate = location.coordinate
                                region.center = location.coordinate
                            }
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Usa Posizione Corrente")
                            }
                            .font(MoveUpFont.body())
                            .foregroundColor(Color.moveUpPrimary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.moveUpPrimary.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .disabled(locationManager.location == nil)
                    }
                    
                    // Radius Slider
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Raggio di Servizio")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            Spacer()
                            
                            Text("\(String(format: "%.1f", radius)) km")
                                .font(MoveUpFont.body())
                                .foregroundColor(Color.moveUpPrimary)
                                .fontWeight(.semibold)
                        }
                        
                        Slider(value: $radius, in: 5...50, step: 0.5)
                            .tint(Color.moveUpPrimary)
                        
                        HStack {
                            Text("5 km")
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpTextSecondary)
                            Spacer()
                            Text("50 km")
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpTextSecondary)
                        }
                    }
                    
                    // Save Button
                    Button(action: saveZone) {
                        Text("Salva Zona")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.moveUpPrimary : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Nuova Zona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("Annulla")
                        }
                        .foregroundColor(Color.moveUpPrimary)
                    }
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    private var isFormValid: Bool {
        !zoneName.isEmpty && selectedCoordinate != nil
    }
    
    private var radiusInMapPoints: CGFloat {
        // Approximate conversion from km to map points (rough estimate)
        CGFloat(radius * 8)
    }
    
    private func saveZone() {
        guard let coordinate = selectedCoordinate else { return }
        
        let newZone = ServiceZone(
            name: zoneName,
            center: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude),
            radiusInMeters: radius * 1000
        )
        
        onSave(newZone)
        dismiss()
    }
}

// Helper for Map Annotations
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Earnings History View
struct EarningsHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod = "Mese"
    
    let periods = ["Settimana", "Mese", "Anno"]
    let monthlyData = [
        ("Gennaio", 1250), ("Febbraio", 1420), ("Marzo", 1680),
        ("Aprile", 1890), ("Maggio", 2100), ("Giugno", 1950)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Picker
                    Picker("Periodo", selection: $selectedPeriod) {
                        ForEach(periods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Total Earnings
                    VStack(spacing: 8) {
                        Text("Guadagno Totale")
                            .font(MoveUpFont.body())
                            .foregroundColor(.moveUpTextSecondary)
                        
                        Text("€ 10.290")
                            .font(MoveUpFont.title(34))
                            .fontWeight(.bold)
                            .foregroundColor(.moveUpPrimary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                            Text("+12% rispetto al mese scorso")
                                .font(MoveUpFont.caption())
                        }
                        .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.moveUpAccent1.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Monthly Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Dettaglio per Mese")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                        
                        ForEach(monthlyData, id: \.0) { month, amount in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(month)
                                        .font(MoveUpFont.body())
                                    Text("\(calculateLessons(amount)) lezioni")
                                        .font(MoveUpFont.caption())
                                        .foregroundColor(.moveUpTextSecondary)
                                }
                                Spacer()
                                Text("€ \(amount)")
                                    .font(MoveUpFont.body())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.moveUpPrimary)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Storico Guadagni")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
        }
    }
    
    private func calculateLessons(_ amount: Int) -> Int {
        return amount / 45
    }
}

// MARK: - Instructor Support View
struct InstructorSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedFAQ: String?
    @State private var showContactForm = false
    
    let faqs = [
        ("Come ricevo i pagamenti?", "I pagamenti vengono elaborati tramite Stripe e accreditati sul tuo conto bancario entro 2-3 giorni lavorativi."),
        ("Posso modificare le tariffe?", "Sì, puoi modificare le tariffe in qualsiasi momento dalla sezione Impostazioni > Tariffe."),
        ("Come gestisco le cancellazioni?", "Gli studenti possono cancellare fino a 24 ore prima. Riceverai una notifica e lo slot tornerà disponibile."),
        ("Come funziona la valutazione?", "Gli studenti possono lasciarti una recensione dopo ogni lezione. Mantieni un rating alto per attrarre più studenti!")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // FAQ Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Domande Frequenti")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                        
                        ForEach(faqs, id: \.0) { question, answer in
                            InstructorFAQCard(
                                question: question,
                                answer: answer,
                                isExpanded: expandedFAQ == question
                            ) {
                                withAnimation {
                                    expandedFAQ = expandedFAQ == question ? nil : question
                                }
                            }
                        }
                    }
                    
                    // Contact Support
                    VStack(spacing: 16) {
                        Text("Hai bisogno di aiuto?")
                            .font(MoveUpFont.subtitle())
                            .fontWeight(.bold)
                        
                        Button(action: {
                            showContactForm = true
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Contatta il Supporto")
                            }
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.moveUpPrimary)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Aiuto e Supporto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") { dismiss() }
                        .foregroundColor(.moveUpPrimary)
                }
            }
            .sheet(isPresented: $showContactForm) {
                ContactSupportForm()
            }
        }
    }
}

struct InstructorFAQCard: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTap) {
                HStack {
                    Text(question)
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                        .foregroundColor(.moveUpTextPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.moveUpPrimary)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(MoveUpFont.body())
                    .foregroundColor(.moveUpTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct ContactSupportForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Oggetto", text: $subject)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    TextEditor(text: $message)
                        .frame(height: 200)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Button(action: {
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }) {
                        Text("Invia Richiesta")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(subject.isEmpty || message.isEmpty ? Color.gray : Color.moveUpPrimary)
                            .cornerRadius(12)
                    }
                    .disabled(subject.isEmpty || message.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Contatta Supporto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annulla") { dismiss() }
                }
            }
            .alert("Richiesta Inviata!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Il team di supporto ti risponderà entro 24 ore.")
            }
        }
    }
}

// MARK: - Calendar Sync Card
struct CalendarSyncCard: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var isExpanded = false
    @State private var isSyncing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var selectedCalendar: EKCalendar?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.moveUpPrimary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sincronizza Calendario")
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                        .foregroundColor(.moveUpTextPrimary)
                    
                    Text(statusText)
                        .font(MoveUpFont.caption())
                        .foregroundColor(.moveUpTextSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.moveUpPrimary)
                }
            }
            
            if isExpanded {
                Divider()
                
                // Calendar Selection
                if calendarManager.authorizationStatus == .authorized || calendarManager.authorizationStatus == .fullAccess {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scegli il calendario")
                            .font(MoveUpFont.caption())
                            .foregroundColor(.moveUpTextSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(calendarManager.getCalendars(), id: \.calendarIdentifier) { calendar in
                                    CalendarChip(
                                        calendar: calendar,
                                        isSelected: selectedCalendar?.calendarIdentifier == calendar.calendarIdentifier
                                    ) {
                                        selectedCalendar = calendar
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    if calendarManager.authorizationStatus == .notDetermined {
                        Button(action: requestCalendarAccess) {
                            HStack {
                                Image(systemName: "lock.open.fill")
                                Text("Autorizza Accesso")
                            }
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.moveUpPrimary)
                            .cornerRadius(12)
                        }
                    } else if calendarManager.authorizationStatus == .denied || calendarManager.authorizationStatus == .restricted {
                        VStack(spacing: 8) {
                            Text("Accesso negato")
                                .font(MoveUpFont.body())
                                .foregroundColor(.red)
                            
                            Button(action: openSettings) {
                                Text("Vai alle Impostazioni")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(.moveUpPrimary)
                            }
                        }
                    } else {
                        Button(action: syncCalendar) {
                            HStack {
                                if isSyncing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                }
                                Text(isSyncing ? "Sincronizzazione..." : "Sincronizza Lezioni")
                            }
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.moveUpPrimary)
                            .cornerRadius(12)
                        }
                        .disabled(isSyncing)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .alert("Errore", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Successo!", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Le tue lezioni sono state sincronizzate con il calendario.")
        }
    }
    
    private var statusText: String {
        switch calendarManager.authorizationStatus {
        case .authorized, .fullAccess:
            return "Collegato"
        case .writeOnly:
            return "Solo scrittura"
        case .denied, .restricted:
            return "Accesso negato"
        case .notDetermined:
            return "Non configurato"
        @unknown default:
            return "Stato sconosciuto"
        }
    }
    
    private func requestCalendarAccess() {
        Task {
            do {
                let granted = try await calendarManager.requestAccess()
                if !granted {
                    await MainActor.run {
                        errorMessage = "Accesso al calendario negato"
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func syncCalendar() {
        Task {
            await MainActor.run {
                isSyncing = true
            }
            
            // Simula sincronizzazione delle lezioni
            // In produzione, qui caricherai le lezioni dal backend e le aggiungerai al calendario
            do {
                // Esempio: Crea un evento di test
                let startDate = Date().addingTimeInterval(3600) // 1 ora da ora
                let endDate = startDate.addingTimeInterval(3600) // 1 ora di durata
                
                _ = try calendarManager.createEvent(
                    title: "Lezione di Tennis",
                    startDate: startDate,
                    endDate: endDate,
                    location: "Campo Tennis Centrale",
                    notes: "Lezione individuale per principianti",
                    calendar: selectedCalendar
                )
                
                await MainActor.run {
                    isSyncing = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isSyncing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Calendar Chip
struct CalendarChip: View {
    let calendar: EKCalendar
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(cgColor: calendar.cgColor))
                    .frame(width: 12, height: 12)
                
                Text(calendar.title)
                    .font(MoveUpFont.caption())
                    .foregroundColor(isSelected ? .white : .moveUpTextPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.moveUpPrimary : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

