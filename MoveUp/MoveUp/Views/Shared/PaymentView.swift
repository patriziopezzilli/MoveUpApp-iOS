//
//  PaymentView.swift
//  MoveUp
//
//  Created by iOS Dev                        if selectedPaymentMethod == .creditCard {loper on 30/12/24.
//

import SwiftUI

enum PaymentMethod: String, CaseIterable {
    case creditCard = "credit_card"
    case applePay = "apple_pay"
    case googlePay = "google_pay"
    
    var displayName: String {
        switch self {
        case .creditCard: return "Carta di Credito"
        case .applePay: return "Apple Pay"
        case .googlePay: return "Google Pay"
        }
    }
    
    var icon: String {
        switch self {
        case .creditCard: return "creditcard"
        case .applePay: return "apple.logo"
        case .googlePay: return "g.circle"
        }
    }
}

struct PaymentView: View {
    let lesson: Lesson
    let instructor: Instructor
    let selectedDate: Date
    let selectedTimeSlot: TimeSlot
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var bookingService = BookingService.shared
    @State private var selectedPaymentMethod: PaymentMethod = .creditCard
    @State private var isProcessingPayment = false
    @State private var showPaymentSuccess = false
    @State private var createdBooking: Booking?
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardholderName = ""
    
    private var totalAmount: Double {
        lesson.price
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: MoveUpSpacing.large) {
                    // Booking Summary
                    bookingSummarySection
                    
                    // Payment Method Selection
                    paymentMethodSection
                    
                    // Payment Details
                    if selectedPaymentMethod == .creditCard {
                        paymentDetailsSection
                    }
                    
                    // Order Total
                    orderTotalSection
                    
                    Spacer(minLength: MoveUpSpacing.xl)
                }
                .padding(.horizontal, MoveUpSpacing.large)
            }
            .navigationTitle("Pagamento")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                paymentButton
            }
        }
        .sheet(isPresented: $showPaymentSuccess) {
            if let booking = createdBooking {
                PaymentSuccessView(
                    booking: booking,
                    lesson: lesson,
                    instructor: instructor,
                    amount: totalAmount,
                    bookingDate: selectedDate
                )
            }
        }
    }
    
    private var bookingSummarySection: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
            Text("Riepilogo Prenotazione")
                .font(MoveUpFont.title(20))
                .foregroundColor(Color.moveUpTextPrimary)
            
            VStack(spacing: MoveUpSpacing.small) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpTextPrimary)
                        
                        Text("con \(instructor.bio.components(separatedBy: ".").first ?? "Istruttore")")
                            .font(MoveUpFont.body())
                            .foregroundColor(Color.moveUpTextSecondary)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Color.moveUpSecondary)
                            Text(selectedDate.formatted(.dateTime.day().month().year()))
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpTextSecondary)
                            
                            Image(systemName: "clock")
                                .foregroundColor(Color.moveUpSecondary)
                            Text("\(selectedTimeSlot.startTime) - \(selectedTimeSlot.endTime)")
                                .font(MoveUpFont.caption())
                                .foregroundColor(Color.moveUpTextSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(lesson.priceFormatted)
                        .font(MoveUpFont.title(18))
                        .foregroundColor(Color.moveUpSecondary)
                }
            }
            .padding(MoveUpSpacing.medium)
            .moveUpCard()
        }
    }
    
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
            Text("Metodo di Pagamento")
                .font(MoveUpFont.title(20))
                .foregroundColor(Color.moveUpTextPrimary)
            
            VStack(spacing: MoveUpSpacing.small) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentSelectionCard(
                        method: method,
                        isSelected: selectedPaymentMethod == method,
                        action: {
                            selectedPaymentMethod = method
                        }
                    )
                }
            }
        }
    }
    
    private var paymentDetailsSection: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
            Text("Dettagli Carta")
                .font(MoveUpFont.title(20))
                .foregroundColor(Color.moveUpTextPrimary)
            
            VStack(spacing: MoveUpSpacing.medium) {
                TextField("Numero Carta", text: $cardNumber)
                    .textFieldStyle(MoveUpTextFieldStyle())
                    .keyboardType(.numberPad)
                
                TextField("Nome Titolare", text: $cardholderName)
                    .textFieldStyle(MoveUpTextFieldStyle())
                
                HStack {
                    TextField("MM/AA", text: $expiryDate)
                        .textFieldStyle(MoveUpTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    TextField("CVV", text: $cvv)
                        .textFieldStyle(MoveUpTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
    }
    
    private var orderTotalSection: some View {
        VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
            Text("Totale Ordine")
                .font(MoveUpFont.title(20))
                .foregroundColor(Color.moveUpTextPrimary)
            
            VStack(spacing: MoveUpSpacing.small) {
                HStack {
                    Text("Lezione (\(lesson.durationFormatted))")
                    Spacer()
                    Text(lesson.priceFormatted)
                }
                
                HStack {
                    Text("Commissioni di servizio")
                    Spacer()
                    Text("€0.00")
                }
                .font(MoveUpFont.body())
                .foregroundColor(Color.moveUpTextSecondary)
                
                Divider()
                
                HStack {
                    Text("Totale")
                        .font(MoveUpFont.subtitle())
                    Spacer()
                    Text(String(format: "€%.2f", totalAmount))
                        .font(MoveUpFont.title(18))
                        .foregroundColor(Color.moveUpSecondary)
                }
            }
            .padding(MoveUpSpacing.medium)
            .moveUpCard()
        }
    }
    
    private var paymentButton: some View {
        VStack {
            Button(action: processPayment) {
                if isProcessingPayment {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Elaborando...")
                    }
                } else {
                    Text("Paga €\(String(format: "%.2f", totalAmount))")
                }
            }
            .buttonStyle(MoveUpButtonStyle(
                backgroundColor: Color.moveUpSecondary,
                foregroundColor: .white
            ))
            .disabled(isProcessingPayment || !isFormValid)
        }
        .padding(.horizontal, MoveUpSpacing.large)
        .padding(.top, MoveUpSpacing.medium)
        .background(Color.moveUpBackground)
    }
    
    private var isFormValid: Bool {
        if selectedPaymentMethod == .applePay || selectedPaymentMethod == .googlePay {
            return true
        }
        return !cardNumber.isEmpty && !cardholderName.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty
    }
    
    private func processPayment() {
        isProcessingPayment = true
        
        // Simulate payment processing with Stripe/backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate successful payment
            let success = simulateStripePayment()
            
            if success {
                // Create and save the booking
                let newBooking = bookingService.createBooking(
                    lesson: lesson,
                    instructor: instructor,
                    selectedDate: selectedDate,
                    selectedTimeSlot: selectedTimeSlot,
                    amount: totalAmount,
                    paymentMethod: selectedPaymentMethod
                )
                
                createdBooking = newBooking
                
                // Show success screen
                isProcessingPayment = false
                showPaymentSuccess = true
                
                print("✅ Payment successful! Booking ID: \(newBooking.id)")
            } else {
                // Handle payment failure (for now just retry)
                isProcessingPayment = false
                print("❌ Payment failed!")
            }
        }
    }
    
    private func simulateStripePayment() -> Bool {
        // In real app, this would integrate with Stripe SDK
        // For now, simulate 95% success rate
        return Int.random(in: 1...100) <= 95
    }
}

// PaymentMethodCard è già definito in UserTabView.swift

struct PaymentSuccessView: View {
    let booking: Booking
    let lesson: Lesson
    let instructor: Instructor
    let amount: Double
    let bookingDate: Date
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: MoveUpSpacing.xl) {
                Spacer()
                
                // Success Animation
                ZStack {
                    Circle()
                        .fill(Color.moveUpSuccess.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.moveUpSuccess)
                }
                
                VStack(spacing: MoveUpSpacing.medium) {
                    Text("Pagamento Completato!")
                        .font(MoveUpFont.title(24))
                        .foregroundColor(Color.moveUpTextPrimary)
                    
                    Text("La tua prenotazione è stata confermata. Riceverai una email di conferma a breve.")
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, MoveUpSpacing.large)
                }
                
                // Booking Details
                VStack(alignment: .leading, spacing: MoveUpSpacing.small) {
                    HStack {
                        Text("Lezione:")
                        Spacer()
                        Text(lesson.title)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Istruttore:")
                        Spacer()
                        Text(instructor.bio.components(separatedBy: ".").first ?? "Istruttore")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Data:")
                        Spacer()
                        Text(bookingDate.formatted(.dateTime.day().month().year()))
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Totale Pagato:")
                        Spacer()
                        Text(String(format: "€%.2f", amount))
                            .fontWeight(.medium)
                            .foregroundColor(Color.moveUpSecondary)
                    }
                }
                .font(MoveUpFont.body())
                .foregroundColor(Color.moveUpTextSecondary)
                .padding(MoveUpSpacing.large)
                .moveUpCard()
                .padding(.horizontal, MoveUpSpacing.large)
                
                Spacer()
                
                VStack(spacing: MoveUpSpacing.medium) {
                    Button("Visualizza Prenotazioni") {
                        NavigationHelper.shared.switchToBookingsTab()
                        dismiss()
                    }
                    .buttonStyle(MoveUpButtonStyle(
                        backgroundColor: Color.moveUpSecondary,
                        foregroundColor: .white
                    ))
                    
                    Button("Torna alla Home") {
                        dismiss()
                    }
                    .buttonStyle(MoveUpSecondaryButtonStyle(
                        borderColor: Color.moveUpSecondary,
                        foregroundColor: Color.moveUpSecondary
                    ))
                }
                .padding(.horizontal, MoveUpSpacing.large)
            }
            .navigationTitle("Successo")
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

struct PaymentSelectionCard: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: method.iconName)
                    .font(.title2)
                    .foregroundColor(Color.moveUpPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.displayName)
                        .font(MoveUpFont.body())
                        .foregroundColor(Color.moveUpTextPrimary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.moveUpPrimary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.moveUpPrimary.opacity(0.1) : Color.moveUpBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.moveUpPrimary : Color.moveUpTextSecondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension PaymentMethod {
    var iconName: String {
        switch self {
        case .creditCard: return "creditcard.fill"
        case .applePay: return "applelogo"
        case .googlePay: return "logo.playstation"
        }
    }
}