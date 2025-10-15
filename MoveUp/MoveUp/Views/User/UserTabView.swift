import SwiftUI
import EventKit

struct UserTabView: View {
    @State private var selectedTab = 0
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                UserHomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationStack {
                InstantBookingMapView()
            }
            .tabItem {
                Image(systemName: "location.fill")
                Text("Vicini")
            }
            .tag(1)
            
            NavigationStack {
                UserBookingsView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Prenotazioni")
            }
            .tag(2)
            
            NavigationStack {
                DiscoverView()
            }
            .tabItem {
                Image(systemName: "sparkles")
                Text("Scopri")
            }
            .tag(3)
            
            NavigationStack {
                UserProfileView()
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Profilo")
            }
            .tag(4)
        }
        .accentColor(Color.moveUpSecondary)
        .environmentObject(calendarManager)
        .onReceive(NotificationCenter.default.publisher(for: .switchToBookingsTab)) { _ in
            selectedTab = 2  // Switch to bookings tab
        }
    }
}

struct UserHomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var searchText = ""
    @State private var showNotifications = false
    @State private var selectedSport: Sport?
    
    // Computed property for filtered lessons
    private var filteredLessons: [Lesson] {
        let allLessons = MockDataService.shared.mockLessons
        
        var filtered = allLessons
        
        // Filter by selected sport
        if let selectedSport = selectedSport {
            filtered = filtered.filter { $0.sport.id == selectedSport.id }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { lesson in
                lesson.title.localizedCaseInsensitiveContains(searchText) ||
                lesson.sport.name.localizedCaseInsensitiveContains(searchText) ||
                lesson.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            Color.moveUpBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                    // Header with search
                    VStack(spacing: MoveUpSpacing.medium) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Ciao, \(authViewModel.currentUser?.name.components(separatedBy: " ").first ?? "Utente")!")
                                    .font(MoveUpFont.title(24))
                                    .foregroundColor(Color.moveUpTextPrimary)
                                
                                Text("Trova la tua prossima lezione")
                                    .font(MoveUpFont.body())
                                    .foregroundColor(Color.moveUpTextSecondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                // Pulsante Mappa - FLAT COLOR
                                NavigationLink(destination: MapView()) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.moveUpPrimary)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "map.fill")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    }
                                    
                                }
                                
                                // Pulsante Notifiche
                                Button(action: { showNotifications = true }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.moveUpCardBackground)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "bell.fill")
                                            .font(.title3)
                                            .foregroundColor(Color.moveUpSecondary)
                                        
                                        // Badge notifiche
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 10, y: -10)
                                    }
                                }
                            }
                        }
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.moveUpTextSecondary)
                            
                            TextField("Cerca sport, istruttore...", text: $searchText)
                                .font(MoveUpFont.body())
                        }
                        .padding(MoveUpSpacing.medium)
                        .background(Color.moveUpCardBackground)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, MoveUpSpacing.large)
                    .padding(.top, MoveUpSpacing.medium)
                    
                    // Sports Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: MoveUpSpacing.medium) {
                            ForEach(Sport.sampleSports) { sport in
                                SportCategoryCard(
                                    sport: sport,
                                    isSelected: selectedSport?.id == sport.id
                                ) {
                                    selectedSport = selectedSport?.id == sport.id ? nil : sport
                                }
                            }
                        }
                        .padding(.horizontal, MoveUpSpacing.large)
                    }
                    .padding(.vertical, MoveUpSpacing.medium)
                    
                    // Lessons List
                    ScrollView {
                        LazyVStack(spacing: MoveUpSpacing.small) {
                            if filteredLessons.isEmpty {
                                VStack(spacing: MoveUpSpacing.medium) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color.moveUpTextSecondary)
                                    
                                    Text("Nessuna lezione trovata")
                                        .font(MoveUpFont.subtitle())
                                        .foregroundColor(Color.moveUpTextSecondary)
                                    
                                    if selectedSport != nil || !searchText.isEmpty {
                                        Button("Cancella filtri") {
                                            selectedSport = nil
                                            searchText = ""
                                        }
                                        .font(MoveUpFont.body())
                                        .foregroundColor(Color.moveUpPrimary)
                                    }
                                }
                                .padding(.top, MoveUpSpacing.xl)
                            } else {
                                ForEach(filteredLessons) { lesson in
                                    NavigationLink(destination: LessonDetailView(lesson: lesson)) {
                                        LessonCardContent(lesson: lesson)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, MoveUpSpacing.medium)
                        .padding(.bottom, MoveUpSpacing.large)
                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
    }

struct SportCategoryCard: View {
    let sport: Sport
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: MoveUpSpacing.small) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.moveUpSecondary : Color.moveUpCardBackground)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: sportIcon(for: sport.name))
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : Color.moveUpSecondary)
                }
                
                Text(sport.name)
                    .font(MoveUpFont.caption())
                    .foregroundColor(isSelected ? Color.moveUpSecondary : Color.moveUpTextSecondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sportIcon(for sportName: String) -> String {
        switch sportName.lowercased() {
        case "tennis": return "tennis.racket"
        case "calcio": return "soccerball"
        case "nuoto": return "figure.pool.swim"
        case "fitness": return "dumbbell.fill"
        case "yoga": return "figure.yoga"
        case "corsa": return "figure.run"
        default: return "sportscourt"
        }
    }
}

struct LessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(MoveUpFont.subtitle(16))
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        Text(lesson.sport.name)
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(lesson.priceFormatted)
                            .font(MoveUpFont.subtitle(18))
                            .foregroundColor(Color.moveUpAccent1)
                        
                        Text(lesson.durationFormatted)
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                    }
                }
                
                // Description
                Text(lesson.description)
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextSecondary)
                    .lineLimit(2)
                
                // Location and Rating
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.caption)
                            .foregroundColor(Color.moveUpTextSecondary)
                        
                        Text(lesson.location.city)
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.moveUpGamification)
                        
                        Text("4.8")
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                        
                        Text("(23)")
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                    }
                }
                
                // Tags
                HStack {
                    TagView(text: lesson.skillLevel.displayName, color: Color.moveUpAccent2)
                    
                    if !lesson.equipment.isEmpty {
                        TagView(text: "Attrezzatura inclusa", color: Color.moveUpSecondary)
                    }
                    
                    Spacer()
                }
            }
            .padding(MoveUpSpacing.medium)
            .moveUpCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Modern Flat Design for NavigationLink compatibility
struct LessonCardContent: View {
    let lesson: Lesson
    
    var body: some View {
        HStack(spacing: 12) {
            // Sport Icon Circle - FLAT
            ZStack {
                Circle()
                    .fill(Color.moveUpSecondary.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: sportIcon(for: lesson.sport.name))
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Color.moveUpSecondary)
            }
            
            // Content - occupa tutto lo spazio disponibile
            VStack(alignment: .leading, spacing: 6) {
                // Title & Price Row
                HStack(alignment: .top) {
                    Text(lesson.title)
                        .font(MoveUpFont.subtitle(16))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.moveUpTextPrimary)
                        .lineLimit(1)
                    
                    Spacer(minLength: 8)
                    
                    Text(lesson.priceFormatted)
                        .font(MoveUpFont.subtitle(16))
                        .fontWeight(.bold)
                        .foregroundColor(Color.moveUpAccent1)
                }
                
                // Sport & Duration
                HStack(spacing: 8) {
                    Text(lesson.sport.name)
                        .font(MoveUpFont.caption())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.moveUpSecondary.opacity(0.1))
                        .foregroundColor(Color.moveUpSecondary)
                        .cornerRadius(4)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(Color.moveUpTextSecondary)
                        Text(lesson.durationFormatted)
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                    }
                    
                    Spacer()
                    
                    // Rating Compact
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.moveUpGamification)
                        Text("4.8")
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                    }
                }
                
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.moveUpTextSecondary)
                    
                    Text(lesson.location.city)
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
            
            // Arrow Indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.moveUpTextSecondary.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.moveUpTextSecondary.opacity(0.08)),
            alignment: .bottom
        )
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
}

struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(MoveUpFont.caption())
            .foregroundColor(color)
            .padding(.horizontal, MoveUpSpacing.small)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}

struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            VStack {
                Text("Filtri")
                    .font(MoveUpFont.title())
                
                Spacer()
                
                Text("Filtri in arrivo...")
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextSecondary)
                
                Spacer()
            }
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

// Placeholder views for other tabs
struct UserBookingsView: View {
    @State private var selectedFilter: BookingFilter = .all
    @State private var showQRScanner = false
    @StateObject private var bookingService = BookingService.shared
    
    private var bookings: [Booking] {
        bookingService.userBookings
    }
    
    private var filteredBookings: [Booking] {
        switch selectedFilter {
        case .all:
            return bookings
        case .upcoming:
            return bookings.filter { $0.lessonDate > Date() && ($0.status == .confirmed || $0.status == .pending) }
        case .completed:
            return bookings.filter { $0.status == .completed }
        case .cancelled:
            return bookings.filter { $0.status == .cancelled || $0.status == .refunded }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                VStack(spacing: 0) {
                    // Filter Tabs
                    filterTabs
                    
                    if filteredBookings.isEmpty {
                        emptyStateView
                    } else {
                        // Bookings List
                        ScrollView {
                            LazyVStack(spacing: MoveUpSpacing.medium) {
                                ForEach(filteredBookings) { booking in
                                    BookingCard(booking: booking) {
                                        // Handle booking actions
                                    }
                                }
                            }
                            .padding(.horizontal, MoveUpSpacing.large)
                            .padding(.top, MoveUpSpacing.medium)
                            .padding(.bottom, 100) // Space for FAB
                        }
                    }
                }
                .navigationTitle("Le Mie Prenotazioni")
                .navigationBarTitleDisplayMode(.large)
            }
            
            // Floating QR Scanner Button - FIGO!
            Button(action: { showQRScanner = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 24, weight: .semibold))
                    Text("Scansiona QR")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.moveUpPrimary)
                .cornerRadius(30)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showQRScanner) {
            if let booking = Booking.sampleBookings.first(where: { $0.status == .confirmed }) {
                QRScannerView(booking: booking) { result in
                    print("QR Scan result: \(result)")
                }
            }
        }
    }
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MoveUpSpacing.small) {
                ForEach(BookingFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        VStack {
                            Text(filter.displayName)
                                .font(MoveUpFont.body())
                                .foregroundColor(selectedFilter == filter ? Color.moveUpSecondary : Color.moveUpTextSecondary)
                            
                            if selectedFilter == filter {
                                Rectangle()
                                    .fill(Color.moveUpSecondary)
                                    .frame(height: 2)
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, MoveUpSpacing.large)
        }
        .padding(.bottom, MoveUpSpacing.small)
        .background(Color.moveUpBackground)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: MoveUpSpacing.large) {
            Spacer()
            
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(Color.moveUpTextSecondary.opacity(0.5))
            
            VStack(spacing: MoveUpSpacing.small) {
                Text("Nessuna Prenotazione")
                    .font(MoveUpFont.title())
                    .foregroundColor(Color.moveUpTextPrimary)
                
                Text("Non hai ancora prenotato alcuna lezione.\nEsplora le lezioni disponibili per iniziare!")
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Esplora Lezioni") {
                // TODO: Switch to explore tab
            }
            .buttonStyle(MoveUpButtonStyle(
                backgroundColor: Color.moveUpSecondary,
                foregroundColor: .white
            ))
            
            Spacer()
        }
        .padding(.horizontal, MoveUpSpacing.xl)
    }
}

enum BookingFilter: CaseIterable {
    case all
    case upcoming
    case completed
    case cancelled
    
    var displayName: String {
        switch self {
        case .all: return "Tutte"
        case .upcoming: return "In Arrivo"
        case .completed: return "Completate"
        case .cancelled: return "Annullate"
        }
    }
}

struct BookingCard: View {
    let booking: Booking
    let onAction: () -> Void
    
    @StateObject private var bookingService = BookingService.shared
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var showCancelConfirmation = false
    @State private var showContactOptions = false
    @State private var showMessageInstructor = false
    @State private var showCalendarSuccess = false
    @State private var calendarError: String?
    
    // Mock data - in real app would fetch from API
    private var lesson: Lesson {
        MockDataService.shared.mockLessons.first!
    }
    
    private var instructor: Instructor {
        MockDataService.shared.mockInstructors.first!
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
            // Header with status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(MoveUpFont.subtitle())
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    Text("con \(instructor.bio.components(separatedBy: ".").first ?? "Istruttore")")
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextSecondary)
                }
                
                Spacer()
                
                StatusBadge(status: booking.status)
            }
            
            // Booking Details
            VStack(spacing: MoveUpSpacing.small) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color.moveUpSecondary)
                        .frame(width: 16)
                    
                    Text(booking.lessonDate.formatted(.dateTime.day().month().year().hour().minute()))
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextSecondary)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "mappin")
                        .foregroundColor(Color.moveUpSecondary)
                        .frame(width: 16)
                    
                    Text(lesson.location.address)
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextSecondary)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "creditcard")
                        .foregroundColor(Color.moveUpSecondary)
                        .frame(width: 16)
                    
                    Text(booking.formattedAmount)
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextSecondary)
                    
                    Spacer()
                    
                    if booking.status == .pending {
                        NavigationLink(destination: PaymentView(
                            lesson: MockDataService.shared.mockLessons[0], // TODO: Get correct lesson
                            instructor: MockDataService.shared.mockInstructors[0], // TODO: Get correct instructor
                            selectedDate: Date(),
                            selectedTimeSlot: TimeSlot(id: "morning-slot", startTime: "10:00", endTime: "11:00", isAvailable: true)
                        )) {
                            Text("Completa Pagamento")
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpSecondary)
                        }
                    }
                }
            }
            
            // Action Buttons
            if booking.status == .confirmed && booking.lessonDate > Date() {
                Divider()
                
                VStack(spacing: MoveUpSpacing.small) {
                    HStack(spacing: MoveUpSpacing.medium) {
                        Button(action: { showContactOptions = true }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Contatta")
                            }
                            .font(MoveUpFont.caption())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.moveUpSecondary)
                            .cornerRadius(8)
                        }
                        
                        Button(action: addToCalendar) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Calendario")
                            }
                            .font(MoveUpFont.caption())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.moveUpPrimary)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Add to Wallet Button
                    NavigationLink(destination: BookingWalletView(
                        booking: booking,
                        lesson: lesson,
                        instructor: instructor
                    )) {
                        HStack {
                            Image(systemName: "wallet.pass.fill")
                            Text("Aggiungi a Wallet")
                        }
                        .font(MoveUpFont.caption())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    
                    // Live Activity Button (iOS 16.1+)
                    if #available(iOS 16.1, *) {
                        Button(action: {
                            let _ = LiveActivityManager.shared.startLessonActivity(
                                booking: booking,
                                lesson: lesson,
                                instructor: instructor
                            )
                        }) {
                            HStack {
                                Image(systemName: "livephoto")
                                Text("Live Activity")
                            }
                            .font(MoveUpFont.caption())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.purple)
                            .cornerRadius(8)
                        }
                    }
                    
                    Button(action: { showCancelConfirmation = true }) {
                        Text("Annulla Prenotazione")
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpError)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.moveUpError.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            } else if booking.status == .completed {
                NavigationLink(destination: ReviewView(
                    booking: booking,
                    lesson: MockDataService.shared.mockLessons[0], // TODO: Get correct lesson from booking
                    isFromInstructor: false
                )) {
                    Text("Lascia Recensione")
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpSecondary)
                }
            }
        }
        .padding(MoveUpSpacing.large)
        .moveUpCard()
        .alert("Annulla Prenotazione", isPresented: $showCancelConfirmation) {
            Button("Annulla", role: .cancel) { }
            Button("Conferma", role: .destructive) {
                cancelBooking()
            }
        } message: {
            Text("Sei sicuro di voler annullare questa prenotazione? Questa azione non può essere annullata.")
        }
        .confirmationDialog("Contatta Istruttore", isPresented: $showContactOptions, titleVisibility: .visible) {
            Button("Chiama") {
                // Chiama l'istruttore
                if let url = URL(string: "tel://+393355678901") {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Invia Messaggio") {
                showMessageInstructor = true
            }
            
            Button("Annulla", role: .cancel) { }
        } message: {
            Text("Come vuoi contattare l'istruttore?")
        }
        .sheet(isPresented: $showMessageInstructor) {
            MessageInstructorView(instructorName: instructor.bio.components(separatedBy: " ").first ?? "Istruttore")
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
                    title: "\(lesson.title) - MoveUp",
                    startDate: booking.lessonDate,
                    endDate: endDate,
                    location: lesson.location.address,
                    notes: "Lezione prenotata tramite MoveUp\nIstruttore: \(instructor.bio.components(separatedBy: ".").first ?? "Istruttore")\nImporto: \(booking.formattedAmount)"
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
    
    private func cancelBooking() {
        // Update booking status to cancelled
        bookingService.cancelBooking(booking)
    }
}

struct StatusBadge: View {
    let status: BookingStatus
    
    var body: some View {
        Text(status.displayName)
            .font(MoveUpFont.caption())
            .foregroundColor(badgeTextColor)
            .padding(.horizontal, MoveUpSpacing.small)
            .padding(.vertical, 4)
            .background(badgeBackgroundColor)
            .cornerRadius(8)
    }
    
    private var badgeTextColor: Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .completed: return Color.moveUpSuccess
        case .cancelled, .refunded, .noShow: return Color.moveUpError
        }
    }
    
    private var badgeBackgroundColor: Color {
        badgeTextColor.opacity(0.1)
    }
}

struct UserRewardsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedBadgeCategory: BadgeCategory? = nil
    
    private var filteredBadges: [Badge] {
        if let category = selectedBadgeCategory {
            return Badge.sampleBadges.filter { $0.category == category }
        }
        return Badge.sampleBadges
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Modern Header Card
                VStack(spacing: 20) {
                    // Points Display
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.moveUpGamification)
                                .frame(width: 100, height: 100)
                            
                            Text("\(authViewModel.currentUser?.points ?? 0)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Punti Totali")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    // Stats Row
                    HStack(spacing: 0) {
                        ModernStatItem(
                            icon: "rosette",
                            value: "\(authViewModel.currentUser?.badges.filter { $0.isUnlocked }.count ?? 0)",
                            title: "Badge Sbloccati"
                        )
                        
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 1, height: 40)
                        
                        ModernStatItem(
                            icon: "target",
                            value: "1000",
                            title: "Obiettivo"
                        )
                        
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 1, height: 40)
                        
                        ModernStatItem(
                            icon: "trophy.fill",
                            value: "\(filteredBadges.filter { $0.isUnlocked }.count)",
                            title: "Completati"
                        )
                    }
                }
                .padding(24)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Filter Categories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Categorie")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ModernFilterChip(
                                title: "Tutti",
                                isSelected: selectedBadgeCategory == nil
                            ) {
                                selectedBadgeCategory = nil
                            }
                            
                            ForEach(BadgeCategory.allCases, id: \.self) { category in
                                ModernFilterChip(
                                    title: category.displayName,
                                    isSelected: selectedBadgeCategory == category
                                ) {
                                    selectedBadgeCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Badges Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(filteredBadges) { badge in
                        ModernBadgeCard(badge: badge)
                    }
                }
                .padding(.bottom, 100) // Extra space for tab bar
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("Premi")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ModernStatItem: View {
    let icon: String
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color.moveUpPrimary)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ModernFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Color.moveUpPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.moveUpPrimary : Color.moveUpPrimary.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct ModernBadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge Icon - FLAT COLOR
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? Color.moveUpGamification : Color(.systemGray5))
                    .frame(width: 60, height: 60)
                
                Image(systemName: badge.imageName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(badge.isUnlocked ? .white : .secondary)
            }
            
            // Badge Info
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(badge.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Progress or Status
            if badge.isUnlocked {
                Text("Completato")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("In Corso")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        
    }
}

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MoveUpFont.caption())
                .foregroundColor(isSelected ? .white : Color.moveUpTextSecondary)
                .padding(.horizontal, MoveUpSpacing.medium)
                .padding(.vertical, MoveUpSpacing.small)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.moveUpPrimary : Color.moveUpCardBackground)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showEditProfile = false
    @State private var showPersonalInfo = false
    @State private var showSportsPreferences = false
    @State private var showLocationSettings = false
    @State private var showNotificationSettings = false
    @State private var showPaymentMethods = false
    @State private var showSupport = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Modern Profile Header - Full Width
                VStack(spacing: 20) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color.moveUpPrimary)
                            .frame(width: 100, height: 100)
                        
                        if let user = authViewModel.currentUser {
                            Text(getInitials(from: user.name))
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // User Info
                    VStack(spacing: 8) {
                        if let user = authViewModel.currentUser {
                            Text(user.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(user.email)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Edit Profile Button
                    Button("Modifica Profilo") {
                        showEditProfile = true
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.moveUpPrimary)
                    .cornerRadius(25)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color.white)
                
                
                // Rest of content with horizontal padding
                VStack(spacing: 24) {
                if let user = authViewModel.currentUser {
                    HStack(spacing: 0) {
                        ModernProfileStat(
                            icon: "star.fill",
                            value: "\(user.points)",
                            title: "Punti",
                            color: .moveUpGamification
                        )
                        
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 1, height: 60)
                        
                        ModernProfileStat(
                            icon: "rosette",
                            value: "\(user.badges.filter { $0.isUnlocked }.count)",
                            title: "Badge",
                            color: .moveUpSecondary
                        )
                        
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 1, height: 60)
                        
                        ModernProfileStat(
                            icon: "figure.run",
                            value: "\(user.completedLessons.count)",
                            title: "Lezioni",
                            color: .moveUpAccent1
                        )
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                }
                
                // Calendar Sync Section
                CalendarSyncCard()
                
                // Profile Options
                VStack(spacing: 16) {
                    ModernProfileSection(icon: "person.crop.circle.fill", title: "Informazioni Personali", subtitle: "Nome, email, telefono") {
                        showPersonalInfo = true
                    }
                    
                    ModernProfileSection(icon: "heart.circle.fill", title: "Sport Preferiti", subtitle: "I tuoi sport del cuore") {
                        showSportsPreferences = true
                    }
                    
                    ModernProfileSection(icon: "location.circle.fill", title: "Posizione", subtitle: "Dove vuoi allenarti") {
                        showLocationSettings = true
                    }
                    
                    ModernProfileSection(icon: "bell.circle.fill", title: "Notifiche", subtitle: "Gestisci le tue notifiche") {
                        showNotificationSettings = true
                    }
                    
                    ModernProfileSection(icon: "creditcard.circle.fill", title: "Pagamenti", subtitle: "Metodi di pagamento") {
                        showPaymentMethods = true
                    }
                    
                    ModernProfileSection(icon: "questionmark.circle.fill", title: "Supporto", subtitle: "Aiuto e FAQ") {
                        showSupport = true
                    }
                }
                
                // Logout Button
                Button("Esci dall'Account") {
                    authViewModel.signOut()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
                
                // Bottom Spacing
                Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .background(Color.moveUpBackground)
        .navigationBarHidden(true)
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showPersonalInfo) {
            PersonalInfoView()
        }
        .sheet(isPresented: $showSportsPreferences) {
            SportsPreferencesView()
        }
        .sheet(isPresented: $showLocationSettings) {
            LocationSettingsView()
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showPaymentMethods) {
            PaymentMethodsView()
        }
        .sheet(isPresented: $showSupport) {
            SupportView()
        }
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: MoveUpSpacing.small) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(MoveUpFont.title(20))
                .foregroundColor(Color.moveUpTextPrimary)
                .fontWeight(.bold)
            
            Text(title)
                .font(MoveUpFont.caption())
                .foregroundColor(Color.moveUpTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MoveUpSpacing.large)
        .moveUpCard()
        .moveUpShadow()
    }
}

struct ProfileSection: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MoveUpSpacing.medium) {
                ZStack {
                    Circle()
                        .fill(Color.moveUpPrimary.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(Color.moveUpPrimary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(MoveUpFont.subtitle(16))
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    Text(subtitle)
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.moveUpTextSecondary)
            }
            .padding(MoveUpSpacing.medium)
            .moveUpCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: MoveUpSpacing.large) {
                    // Profile Image Section
                    VStack(spacing: MoveUpSpacing.medium) {
                        ZStack {
                            Circle()
                                .fill(Color.moveUpSecondary.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            if let user = authViewModel.currentUser {
                                Text(getInitials(from: user.name))
                                    .font(MoveUpFont.title(32))
                                    .foregroundColor(Color.moveUpSecondary)
                            }
                        }
                        
                        Button("Cambia Foto") {
                            // Implementazione futura
                        }
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpPrimary)
                    }
                    
                    // Form Fields
                    VStack(spacing: MoveUpSpacing.medium) {
                        VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
                            Text("Nome")
                                .font(MoveUpFont.body())
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            TextField("Inserisci il tuo nome", text: $firstName)
                                .textFieldStyle(MoveUpTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
                            Text("Cognome")
                                .font(MoveUpFont.body())
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            TextField("Inserisci il tuo cognome", text: $lastName)
                                .textFieldStyle(MoveUpTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
                            Text("Telefono")
                                .font(MoveUpFont.body())
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            TextField("Inserisci il tuo numero", text: $phoneNumber)
                                .textFieldStyle(MoveUpTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                    }
                    
                    Button("Salva Modifiche") {
                        // Implementazione salvataggio
                        dismiss()
                    }
                    .buttonStyle(MoveUpButtonStyle(
                        backgroundColor: Color.moveUpPrimary,
                        foregroundColor: .white
                    ))
                    .padding(.top, MoveUpSpacing.large)
                }
                .padding(MoveUpSpacing.large)
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Modifica Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let user = authViewModel.currentUser {
                let nameComponents = user.name.components(separatedBy: " ")
                firstName = nameComponents.first ?? ""
                lastName = nameComponents.count > 1 ? Array(nameComponents[1...]).joined(separator: " ") : ""
                phoneNumber = user.phoneNumber.isEmpty ? "" : user.phoneNumber
            }
        }
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
}

struct PersonalInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: MoveUpSpacing.large) {
                    if let user = authViewModel.currentUser {
                        ProfileInfoRow(title: "Nome Completo", value: user.name)
                        ProfileInfoRow(title: "Email", value: user.email)
                        ProfileInfoRow(title: "Telefono", value: user.phoneNumber.isEmpty ? "Non specificato" : user.phoneNumber)
                        ProfileInfoRow(title: "Tipo Account", value: user.email.contains("instructor") ? "Istruttore" : "Utente")
                    }
                }
                .padding(MoveUpSpacing.large)
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Informazioni Personali")
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

struct SportsPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSports: Set<String> = []
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: MoveUpSpacing.large) {
                    Text("Seleziona i tuoi sport preferiti per ricevere suggerimenti personalizzati")
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: MoveUpSpacing.medium) {
                        ForEach(Sport.sampleSports) { sport in
                            SportSelectionCard(
                                sport: sport,
                                isSelected: selectedSports.contains(sport.id)
                            ) {
                                if selectedSports.contains(sport.id) {
                                    selectedSports.remove(sport.id)
                                } else {
                                    selectedSports.insert(sport.id)
                                }
                            }
                        }
                    }
                }
                .padding(MoveUpSpacing.large)
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Sport Preferiti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        dismiss()
                    }
                    .foregroundColor(Color.moveUpPrimary)
                }
            }
        }
    }
}

struct LocationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: MoveUpSpacing.large) {
                    Text("Gestisci dove vuoi allenarti")
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: MoveUpSpacing.medium) {
                        SettingsRow(
                            icon: "location.circle.fill",
                            title: "Posizione Attuale",
                            subtitle: "Roma, Italia"
                        ) {
                            // Implementazione futura
                        }
                        
                        SettingsRow(
                            icon: "scope",
                            title: "Raggio di Ricerca",
                            subtitle: "10 km"
                        ) {
                            // Implementazione futura
                        }
                        
                        SettingsRow(
                            icon: "mappin.circle.fill",
                            title: "Luoghi Preferiti",
                            subtitle: "Aggiungi palestre o zone preferite"
                        ) {
                            // Implementazione futura
                        }
                    }
                }
                .padding(MoveUpSpacing.large)
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Posizione")
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

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = false
    @State private var lessonReminders = true
    @State private var newBadges = true
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: MoveUpSpacing.large) {
                    VStack(spacing: MoveUpSpacing.medium) {
                        ToggleRow(title: "Notifiche Push", subtitle: "Ricevi notifiche sul dispositivo", isOn: $pushNotifications)
                        ToggleRow(title: "Email", subtitle: "Ricevi notifiche via email", isOn: $emailNotifications)
                        ToggleRow(title: "Promemoria Lezioni", subtitle: "Ti ricordiamo le lezioni programmate", isOn: $lessonReminders)
                        ToggleRow(title: "Nuovi Badge", subtitle: "Celebra i tuoi traguardi", isOn: $newBadges)
                    }
                }
                .padding(MoveUpSpacing.large)
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Notifiche")
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

struct PaymentMethodsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: MoveUpSpacing.large) {
                    Text("Gestisci i tuoi metodi di pagamento")
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: MoveUpSpacing.medium) {
                        PaymentMethodCard(
                            type: "Carta di Credito",
                            lastFour: "1234",
                            isDefault: true
                        )
                        
                        Button("Aggiungi Metodo di Pagamento") {
                            // Implementazione futura
                        }
                        .buttonStyle(MoveUpButtonStyle(
                            backgroundColor: Color.moveUpPrimary,
                            foregroundColor: .white
                        ))
                    }
                }
                .padding(MoveUpSpacing.large)
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Pagamenti")
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

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFAQ = false
    @State private var showContact = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: MoveUpSpacing.large) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.moveUpPrimary)
                        
                        Text("Come possiamo aiutarti?")
                            .font(MoveUpFont.title())
                            .foregroundColor(.primary)
                        
                        Text("Siamo qui per supportarti in ogni momento")
                            .font(MoveUpFont.body())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: MoveUpSpacing.medium) {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "FAQ",
                            subtitle: "Domande frequenti"
                        ) {
                            showFAQ = true
                        }
                        
                        SettingsRow(
                            icon: "envelope.circle.fill",
                            title: "Contattaci",
                            subtitle: "Invia un messaggio al supporto"
                        ) {
                            showContact = true
                        }
                        
                        SettingsRow(
                            icon: "doc.circle.fill",
                            title: "Termini di Servizio",
                            subtitle: "Leggi i nostri termini"
                        ) {
                            showTerms = true
                        }
                        
                        SettingsRow(
                            icon: "lock.circle.fill",
                            title: "Privacy Policy",
                            subtitle: "La tua privacy è importante"
                        ) {
                            showPrivacy = true
                        }
                    }
                    
                    // Contatti diretti
                    VStack(spacing: 16) {
                        Text("Contatti Diretti")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(.moveUpPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            ContactInfoCard(
                                icon: "envelope.fill",
                                title: "Email",
                                value: "support@moveup.com",
                                color: .moveUpPrimary
                            )
                            
                            ContactInfoCard(
                                icon: "phone.fill",
                                title: "Telefono",
                                value: "+39 02 1234 5678",
                                color: .moveUpAccent1
                            )
                            
                            ContactInfoCard(
                                icon: "clock.fill",
                                title: "Orari",
                                value: "Lun-Ven 9:00-18:00",
                                color: .moveUpSecondary
                            )
                        }
                    }
                }
                .padding(MoveUpSpacing.large)
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Supporto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showFAQ) {
                FAQView()
            }
            .sheet(isPresented: $showContact) {
                ContactSupportView()
            }
            .sheet(isPresented: $showTerms) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyPolicyView()
            }
        }
    }
}

// MARK: - Contact Info Card
struct ContactInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(MoveUpFont.caption())
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(MoveUpFont.body())
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        
    }
}

// MARK: - FAQ View
struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedFAQ: Int? = nil
    
    let faqs = [
        FAQ(question: "Come posso prenotare una lezione?", 
            answer: "Naviga tra le lezioni disponibili nella home, seleziona quella che ti interessa e clicca su 'Prenota'. Scegli data e orario e conferma la prenotazione."),
        FAQ(question: "Posso cancellare una prenotazione?", 
            answer: "Sì, puoi cancellare una prenotazione fino a 24 ore prima dell'inizio della lezione senza penali. Dopo questo periodo, verrà trattenuto il 50% del costo."),
        FAQ(question: "Come funziona il sistema punti?", 
            answer: "Guadagni punti completando lezioni, raggiungendo obiettivi e sbloccando badge. I punti possono essere usati per ottenere sconti sulle lezioni future."),
        FAQ(question: "Come posso diventare istruttore?", 
            answer: "Contatta il supporto tramite l'apposito modulo indicando le tue qualifiche e certificazioni. Il nostro team valuterà la tua candidatura entro 48 ore."),
        FAQ(question: "Quali metodi di pagamento accettate?", 
            answer: "Accettiamo carte di credito/debito (Visa, Mastercard, American Express), PayPal e Apple Pay per una maggiore comodità."),
        FAQ(question: "Come posso modificare il mio profilo?", 
            answer: "Vai nella sezione Profilo, clicca su 'Modifica Profilo' e aggiorna le informazioni che desideri. Ricorda di salvare le modifiche."),
        FAQ(question: "La mia posizione è sicura?", 
            answer: "Sì, utilizziamo la tua posizione solo per mostrarti lezioni e istruttori nelle vicinanze. I dati non vengono condivisi con terze parti."),
        FAQ(question: "Cosa succede in caso di maltempo?", 
            answer: "L'istruttore può decidere di cancellare o spostare la lezione. Riceverai una notifica e potrai scegliere una nuova data o ricevere un rimborso completo.")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                        FAQCard(
                            faq: faq,
                            isExpanded: expandedFAQ == index,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    expandedFAQ = expandedFAQ == index ? nil : index
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundColor(.moveUpPrimary)
                }
            }
        }
    }
}

struct FAQ {
    let question: String
    let answer: String
}

struct FAQCard: View {
    let faq: FAQ
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTap) {
                HStack {
                    Text(faq.question)
                        .font(MoveUpFont.body())
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.moveUpPrimary)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            
            if isExpanded {
                Text(faq.answer)
                    .font(MoveUpFont.body())
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        
    }
}

// MARK: - Contact Support View
struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.moveUpPrimary)
                        
                        Text("Contatta il Supporto")
                            .font(MoveUpFont.title())
                            .foregroundColor(.primary)
                        
                        Text("Ti risponderemo entro 24 ore")
                            .font(MoveUpFont.body())
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        // Oggetto
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Oggetto")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("Inserisci l'oggetto", text: $subject)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Messaggio
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Messaggio")
                                .font(MoveUpFont.body())
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $message)
                                .frame(height: 200)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Invia button
                        Button(action: {
                            // In produzione: invia email al supporto
                            showSuccessAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Invia Messaggio")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(subject.isEmpty || message.isEmpty ? Color.gray : Color.moveUpPrimary)
                            .cornerRadius(12)
                        }
                        .disabled(subject.isEmpty || message.isEmpty)
                    }
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Contattaci")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundColor(.moveUpPrimary)
                }
            }
            .alert("Messaggio Inviato!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Il tuo messaggio è stato inviato al supporto. Ti risponderemo presto!")
            }
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Termini di Servizio")
                        .font(MoveUpFont.title())
                        .foregroundColor(.moveUpPrimary)
                    
                    Group {
                        SectionTitle(title: "1. Accettazione dei Termini")
                        SectionText(text: "Utilizzando MoveUp, accetti di essere vincolato da questi termini di servizio. Se non accetti questi termini, non utilizzare l'applicazione.")
                        
                        SectionTitle(title: "2. Utilizzo del Servizio")
                        SectionText(text: "MoveUp è una piattaforma che connette utenti e istruttori sportivi. Gli utenti possono prenotare lezioni e gli istruttori possono offrire i loro servizi.")
                        
                        SectionTitle(title: "3. Prenotazioni e Pagamenti")
                        SectionText(text: "Le prenotazioni sono vincolanti. I pagamenti vengono elaborati in modo sicuro. Le cancellazioni sono soggette alla politica di cancellazione (24 ore prima).")
                        
                        SectionTitle(title: "4. Responsabilità")
                        SectionText(text: "MoveUp funge da intermediario. Gli istruttori sono responsabili della qualità delle lezioni. Gli utenti sono responsabili del proprio comportamento durante le lezioni.")
                        
                        SectionTitle(title: "5. Privacy")
                        SectionText(text: "I tuoi dati personali vengono trattati secondo la nostra Privacy Policy. Non condividiamo i tuoi dati con terze parti senza il tuo consenso.")
                        
                        SectionTitle(title: "6. Modifiche ai Termini")
                        SectionText(text: "Ci riserviamo il diritto di modificare questi termini in qualsiasi momento. Le modifiche saranno comunicate tramite l'app.")
                    }
                    
                    Text("Ultimo aggiornamento: Ottobre 2025")
                        .font(MoveUpFont.caption())
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Termini di Servizio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundColor(.moveUpPrimary)
                }
            }
        }
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(MoveUpFont.title())
                        .foregroundColor(.moveUpPrimary)
                    
                    Group {
                        SectionTitle(title: "1. Raccolta dei Dati")
                        SectionText(text: "Raccogliamo informazioni personali come nome, email, posizione GPS per fornire il nostro servizio. I dati vengono raccolti solo con il tuo consenso esplicito.")
                        
                        SectionTitle(title: "2. Utilizzo dei Dati")
                        SectionText(text: "Utilizziamo i tuoi dati per: fornire il servizio, elaborare pagamenti, inviare notifiche, mostrare lezioni nelle vicinanze, migliorare l'esperienza utente.")
                        
                        SectionTitle(title: "3. Posizione GPS")
                        SectionText(text: "La tua posizione viene utilizzata esclusivamente per mostrarti lezioni e istruttori nelle vicinanze. Non tracciamo i tuoi movimenti e non condividiamo la tua posizione con terze parti.")
                        
                        SectionTitle(title: "4. Condivisione dei Dati")
                        SectionText(text: "Non vendiamo i tuoi dati personali. Condividiamo informazioni solo con: istruttori (per le prenotazioni), processori di pagamento (per transazioni), autorità legali (se richiesto per legge).")
                        
                        SectionTitle(title: "5. Sicurezza")
                        SectionText(text: "Utilizziamo crittografia SSL/TLS per proteggere i tuoi dati. I pagamenti sono elaborati da servizi certificati PCI-DSS. Implementiamo misure di sicurezza appropriate.")
                        
                        SectionTitle(title: "6. I Tuoi Diritti")
                        SectionText(text: "Hai il diritto di: accedere ai tuoi dati, modificare i tuoi dati, eliminare il tuo account, revocare il consenso, esportare i tuoi dati.")
                        
                        SectionTitle(title: "7. Cookie e Tracking")
                        SectionText(text: "Utilizziamo cookie tecnici necessari per il funzionamento dell'app. Non utilizziamo cookie di profilazione o tracking di terze parti.")
                    }
                    
                    Text("Ultimo aggiornamento: Ottobre 2025")
                        .font(MoveUpFont.caption())
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundColor(.moveUpPrimary)
                }
            }
        }
    }
}

// MARK: - Section Components
struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(MoveUpFont.subtitle())
            .fontWeight(.bold)
            .foregroundColor(.moveUpPrimary)
            .padding(.top, 8)
    }
}

struct SectionText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(MoveUpFont.body())
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Supporting Components

struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
            Text(title)
                .font(MoveUpFont.caption())
                .foregroundColor(Color.moveUpTextSecondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(MoveUpFont.body())
                .foregroundColor(Color.moveUpTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MoveUpSpacing.medium)
        .moveUpCard()
    }
}

struct SportSelectionCard: View {
    let sport: Sport
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: MoveUpSpacing.small) {
                Image(systemName: sportIcon(for: sport.name))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color.moveUpSecondary)
                
                Text(sport.name)
                    .font(MoveUpFont.caption())
                    .foregroundColor(isSelected ? .white : Color.moveUpTextPrimary)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.moveUpSecondary : Color.moveUpCardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.moveUpSecondary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sportIcon(for sportName: String) -> String {
        switch sportName.lowercased() {
        case "tennis": return "tennis.racket"
        case "calcio": return "soccerball"
        case "nuoto": return "figure.pool.swim"
        case "fitness": return "dumbbell.fill"
        case "yoga": return "figure.yoga"
        case "corsa": return "figure.run"
        default: return "sportscourt"
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MoveUpSpacing.medium) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color.moveUpPrimary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    Text(subtitle)
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.moveUpTextSecondary)
            }
            .padding(MoveUpSpacing.medium)
            .moveUpCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextPrimary)
                
                Text(subtitle)
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color.moveUpSecondary)
        }
        .padding(MoveUpSpacing.medium)
        .moveUpCard()
    }
}

struct PaymentMethodCard: View {
    let type: String
    let lastFour: String
    let isDefault: Bool
    
    var body: some View {
        HStack(spacing: MoveUpSpacing.medium) {
            Image(systemName: "creditcard.fill")
                .font(.title2)
                .foregroundColor(Color.moveUpPrimary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(type)
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextPrimary)
                
                Text("**** **** **** \(lastFour)")
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
            }
            
            Spacer()
            
            if isDefault {
                Text("Principale")
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpSuccess)
                    .padding(.horizontal, MoveUpSpacing.small)
                    .padding(.vertical, 2)
                    .background(Color.moveUpSuccess.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(MoveUpSpacing.medium)
        .moveUpCard()
    }
}

struct BadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: MoveUpSpacing.small) {
            // Badge Icon with unlock state
            ZStack {
                Circle()
                    .fill(badgeBackgroundColor)
                    .frame(width: 60, height: 60)
                
                if badge.isUnlocked {
                    Circle()
                        .stroke(rarityColor, lineWidth: 3)
                        .frame(width: 60, height: 60)
                }
                
                Image(systemName: badge.imageName)
                    .font(.system(size: 24))
                    .foregroundColor(badge.isUnlocked ? rarityColor : Color.moveUpTextSecondary)
                    .opacity(badge.isUnlocked ? 1.0 : 0.5)
            }
            
            // Badge Info
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(MoveUpFont.subtitle(12))
                    .foregroundColor(badge.isUnlocked ? Color.moveUpTextPrimary : Color.moveUpTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(badge.description)
                    .font(MoveUpFont.caption())
                    .foregroundColor(Color.moveUpTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Status indicator
                if badge.isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(Color.moveUpSuccess)
                        
                        Text("Sbloccato")
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpSuccess)
                    }
                } else if let points = badge.pointsRequired {
                    Text("\(points) punti")
                        .font(MoveUpFont.caption())
                        .foregroundColor(Color.moveUpTextTertiary)
                }
            }
        }
        .padding(MoveUpSpacing.medium)
        .frame(maxWidth: .infinity, minHeight: 160)
        .moveUpCard(backgroundColor: badge.isUnlocked ? Color.moveUpCardBackground : Color.moveUpCardBackground.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(badge.isUnlocked ? rarityColor.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
    
    private var badgeBackgroundColor: Color {
        if badge.isUnlocked {
            return rarityColor.opacity(0.2)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private var rarityColor: Color {
        switch badge.rarity {
        case .common:
            return Color.gray
        case .rare:
            return Color.blue
        case .epic:
            return Color.purple
        case .legendary:
            return Color.orange
        }
    }
}

struct ModernProfileStat: View {
    let icon: String
    let value: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ModernProfileSection: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.moveUpPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.moveUpPrimary.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Message Instructor View
struct MessageInstructorView: View {
    @Environment(\.dismiss) private var dismiss
    let instructorName: String
    
    @State private var message = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.moveUpPrimary)
                        
                        Text("Messaggio per l'Istruttore")
                            .font(MoveUpFont.title())
                            .foregroundColor(.primary)
                        
                        Text(instructorName)
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Message field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Il tuo messaggio")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $message)
                            .frame(height: 200)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.moveUpPrimary.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text("L'istruttore riceverà il tuo messaggio via email e potrà risponderti direttamente.")
                            .font(MoveUpFont.caption())
                            .foregroundColor(.secondary)
                    }
                    
                    // Suggerimenti rapidi
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggerimenti rapidi")
                            .font(MoveUpFont.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        QuickMessageButton(text: "Ho bisogno di spostare la lezione", action: {
                            message = "Ciao, avrei bisogno di spostare la lezione. Sei disponibile in un altro orario?"
                        })
                        
                        QuickMessageButton(text: "Ho una domanda sull'attrezzatura", action: {
                            message = "Ciao, volevo chiederti informazioni sull'attrezzatura necessaria per la lezione."
                        })
                        
                        QuickMessageButton(text: "Come posso prepararmi?", action: {
                            message = "Ciao, è la mia prima lezione. Hai qualche consiglio su come prepararmi?"
                        })
                    }
                    
                    // Send button
                    Button(action: {
                        sendMessage()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Invia Messaggio")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(message.isEmpty ? Color.gray : Color.moveUpPrimary)
                        .cornerRadius(12)
                    }
                    .disabled(message.isEmpty)
                }
                .padding()
            }
            .background(Color.moveUpBackground)
            .navigationTitle("Contatta Istruttore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundColor(.moveUpPrimary)
                }
            }
            .alert("Messaggio Inviato!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Il tuo messaggio è stato inviato all'istruttore. Riceverai una risposta via email.")
            }
        }
    }
    
    private func sendMessage() {
        // In produzione: invia messaggio tramite API
        showSuccessAlert = true
    }
}

struct QuickMessageButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(MoveUpFont.body())
                    .foregroundColor(.moveUpPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.moveUpPrimary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            
        }
    }
}

struct UserTabView_Previews: PreviewProvider {
    static var previews: some View {
        UserTabView()
            .environmentObject(AuthenticationViewModel())
    }
}
