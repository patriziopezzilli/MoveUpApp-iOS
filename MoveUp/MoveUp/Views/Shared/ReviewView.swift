import SwiftUI

struct ReviewView: View {
    let booking: Booking
    let lesson: Lesson
    let isFromInstructor: Bool
    
    @Environment(\.dismiss) private var dismiss
    @State private var rating = 0
    @State private var comment = ""
    @State private var isSubmitting = false
    
    var revieweeType: String {
        isFromInstructor ? "studente" : "istruttore"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: MoveUpSpacing.large) {
                    // Header
                    VStack(spacing: MoveUpSpacing.medium) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.moveUpGamification)
                        
                        Text("Valuta il tuo \(revieweeType)")
                            .font(MoveUpFont.title())
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        Text("La tua opinione aiuta la community MoveUp")
                            .font(MoveUpFont.body())
                            .foregroundColor(Color.moveUpTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Lesson Summary
                    VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
                        Text("Lezione")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title)
                                    .font(MoveUpFont.body())
                                    .foregroundColor(Color.moveUpTextPrimary)
                                
                                Text(booking.scheduledDate.formatted())
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(Color.moveUpTextSecondary)
                            }
                            
                            Spacer()
                            
                            Text(lesson.sport.name)
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpSecondary)
                                .padding(.horizontal, MoveUpSpacing.small)
                                .padding(.vertical, 4)
                                .background(Color.moveUpSecondary.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(MoveUpSpacing.medium)
                    .moveUpCard()
                    
                    // Rating Section
                    VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                        Text("Valutazione")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        HStack {
                            Text("Come è stata l'esperienza?")
                                .font(MoveUpFont.body())
                                .foregroundColor(Color.moveUpTextSecondary)
                            
                            Spacer()
                        }
                        
                        HStack(spacing: MoveUpSpacing.small) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    rating = star
                                }) {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.system(size: 30))
                                        .foregroundColor(star <= rating ? .moveUpGamification : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Spacer()
                        }
                        
                        if rating > 0 {
                            Text(ratingDescription)
                                .font(MoveUpFont.body())
                                .foregroundColor(Color.moveUpSecondary)
                                .transition(.opacity.combined(with: .slide))
                        }
                    }
                    .padding(MoveUpSpacing.medium)
                    .moveUpCard()
                    
                    // Comment Section
                    VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                        Text("Commento (opzionale)")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        TextField(
                            "Condividi la tua esperienza...",
                            text: $comment,
                            axis: .vertical
                        )
                        .lineLimit(4...8)
                        .font(MoveUpFont.body())
                        .padding(MoveUpSpacing.medium)
                        .background(Color.moveUpCardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(MoveUpSpacing.medium)
                    .moveUpCard()
                    
                    // Gamification Preview
                    if rating > 0 {
                        VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                            Text("Ricompensa")
                                .font(MoveUpFont.subtitle())
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundColor(.moveUpGamification)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Guadagni +10 punti")
                                        .font(MoveUpFont.body())
                                        .foregroundColor(Color.moveUpTextPrimary)
                                    
                                    Text("Per aver lasciato una recensione")
                                        .font(MoveUpFont.caption())
                                        .foregroundColor(Color.moveUpTextSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(MoveUpSpacing.medium)
                        .moveUpCard(backgroundColor: .moveUpGamification.opacity(0.1))
                        .transition(.opacity.combined(with: .slide))
                    }
                }
                .padding(.horizontal, MoveUpSpacing.large)
                .padding(.vertical, MoveUpSpacing.medium)
            }
            .navigationTitle("Recensione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Invia") {
                        submitReview()
                    }
                    .disabled(rating == 0 || isSubmitting)
                    .foregroundColor(rating > 0 && !isSubmitting ? Color.moveUpSecondary : .gray)
                }
            }
        }
        .animation(.easeInOut, value: rating)
    }
    
    private var ratingDescription: String {
        switch rating {
        case 1: return "Non soddisfatto"
        case 2: return "Migliorabile"
        case 3: return "Buono"
        case 4: return "Molto buono"
        case 5: return "Eccellente!"
        default: return ""
        }
    }
    
    private func submitReview() {
        isSubmitting = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Track analytics
            AnalyticsHelper.shared.trackUserAction(.reviewSubmitted(rating: rating))
            
            isSubmitting = false
            dismiss()
        }
    }
}

// MARK: - Reviews List View
struct ReviewsListView: View {
    let instructorId: String
    @State private var reviews: [ReviewWithUser] = []
    @State private var isLoading = true
    
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        return reviews.map { Double($0.review.rating) }.reduce(0, +) / Double(reviews.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.large) {
            // Rating Summary
            VStack(spacing: MoveUpSpacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: MoveUpSpacing.small) {
                            Text(String(format: "%.1f", averageRating))
                                .font(MoveUpFont.title(32))
                                .foregroundColor(Color.moveUpTextPrimary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundColor(
                                                Double(star) <= averageRating ?
                                                    .moveUpGamification : .gray.opacity(0.3)
                                            )
                                    }
                                }
                                
                                Text("\(reviews.count) recensioni")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(Color.moveUpTextSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                // Rating Distribution
                VStack(spacing: MoveUpSpacing.small) {
                    ForEach((1...5).reversed(), id: \.self) { star in
                        RatingBarView(
                            rating: star,
                            count: reviews.filter { $0.review.rating == star }.count,
                            total: reviews.count
                        )
                    }
                }
            }
            .padding(MoveUpSpacing.medium)
            .moveUpCard()
            
            // Reviews List
            VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                Text("Recensioni")
                    .font(MoveUpFont.subtitle())
                    .foregroundColor(Color.moveUpTextPrimary)
                
                if isLoading {
                    ForEach(0..<3, id: \.self) { _ in
                        ReviewCardSkeleton()
                    }
                } else {
                    ForEach(reviews, id: \.review.id) { reviewWithUser in
                        ReviewCard(reviewWithUser: reviewWithUser)
                    }
                }
            }
        }
        .onAppear {
            loadReviews()
        }
    }
    
    private func loadReviews() {
        // Simulate loading reviews
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            reviews = sampleReviews
            isLoading = false
        }
    }
    
    private let sampleReviews: [ReviewWithUser] = [
        ReviewWithUser(
            review: Review(
                id: "1",
                bookingId: "booking1",
                reviewerId: "user1",
                revieweeId: "instructor1",
                rating: 5,
                comment: "Esperienza fantastica! Marco è un istruttore molto professionale e paziente. Ho imparato tantissimo in una sola lezione.",
                isFromInstructor: false,
                createdAt: Date().addingTimeInterval(-86400 * 3),
                updatedAt: Date().addingTimeInterval(-86400 * 3)
            ),
            userName: "Mario Rossi",
            userInitials: "MR"
        ),
        ReviewWithUser(
            review: Review(
                id: "2",
                bookingId: "booking2",
                reviewerId: "user2",
                revieweeId: "instructor1",
                rating: 4,
                comment: "Ottima lezione, istruttore preparato. Consiglio!",
                isFromInstructor: false,
                createdAt: Date().addingTimeInterval(-86400 * 7),
                updatedAt: Date().addingTimeInterval(-86400 * 7)
            ),
            userName: "Giulia Verdi",
            userInitials: "GV"
        )
    ]
}

struct ReviewWithUser {
    let review: Review
    let userName: String
    let userInitials: String
}

struct RatingBarView: View {
    let rating: Int
    let count: Int
    let total: Int
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        HStack(spacing: MoveUpSpacing.small) {
            Text("\(rating)")
                .font(MoveUpFont.caption())
                .foregroundColor(Color.moveUpTextSecondary)
                .frame(width: 12)
            
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundColor(.moveUpGamification)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.moveUpGamification)
                        .frame(width: geometry.size.width * percentage, height: 4)
                }
            }
            .frame(height: 4)
            
            Text("\(count)")
                .font(MoveUpFont.caption())
                .foregroundColor(Color.moveUpTextSecondary)
                .frame(width: 20, alignment: .trailing)
        }
    }
}

struct ReviewCard: View {
    let reviewWithUser: ReviewWithUser
    
    var body: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
            HStack {
                Circle()
                    .fill(Color.moveUpSecondary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(reviewWithUser.userInitials)
                            .font(MoveUpFont.body())
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(reviewWithUser.userName)
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    HStack(spacing: 4) {
                        HStack(spacing: 1) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(
                                        star <= reviewWithUser.review.rating ?
                                            .moveUpGamification : .gray.opacity(0.3)
                                    )
                            }
                        }
                        
                        Text(reviewWithUser.review.createdAt.formatted(.relative(presentation: .named)))
                            .font(MoveUpFont.caption())
                            .foregroundColor(Color.moveUpTextSecondary)
                    }
                }
                
                Spacer()
            }
            
            if let comment = reviewWithUser.review.comment, !comment.isEmpty {
                Text(comment)
                    .font(MoveUpFont.body())
                    .foregroundColor(Color.moveUpTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(MoveUpSpacing.medium)
        .moveUpCard()
    }
}

struct ReviewCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
            HStack {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 100, height: 12)
                        .cornerRadius(6)
                    
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 60, height: 8)
                        .cornerRadius(4)
                }
                
                Spacer()
            }
            
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 40)
                .cornerRadius(8)
        }
        .padding(MoveUpSpacing.medium)
        .moveUpCard()
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView(
            booking: Booking(
                id: "1",
                lessonId: "lesson1",
                instructorId: "instructor1",
                userId: "user1",
                scheduledDate: Date(),
                status: .completed,
                paymentStatus: .captured,
                totalAmount: 45.0,
                createdAt: Date(),
                updatedAt: Date()
            ),
            lesson: MockDataService.shared.mockLessons.first!,
            isFromInstructor: false
        )
    }
}
