//
//  BookingService.swift
//  MoveUp
//
//  Created by AI Assistant on 07/10/25.
//

import Foundation
import Combine

class BookingService: ObservableObject {
    static let shared = BookingService()
    
    @Published var userBookings: [Booking] = []
    
    private init() {
        // Load sample bookings initially
        loadSampleBookings()
    }
    
    private func loadSampleBookings() {
        // Load existing sample data
        userBookings = Booking.sampleBookings
    }
    
    func createBooking(
        lesson: Lesson,
        instructor: Instructor,
        selectedDate: Date,
        selectedTimeSlot: TimeSlot,
        amount: Double,
        paymentMethod: PaymentMethod
    ) -> Booking {
        let newBooking = Booking(
            id: UUID().uuidString,
            lessonId: lesson.id,
            instructorId: instructor.userId,
            userId: "current_user_id", // In real app, get from AuthService
            scheduledDate: selectedDate,
            status: .confirmed, // Booking confirmed after successful payment
            paymentStatus: .captured,
            totalAmount: amount,
            notes: nil,
            createdAt: Date(),
            updatedAt: Date(),
            paymentId: UUID().uuidString, // Mock payment ID
            refundId: nil
        )
        
        // Add to user bookings
        userBookings.append(newBooking)
        
        // In a real app, this would save to backend/local storage
        print("✅ Booking created: \(newBooking.id)")
        print("📅 Lesson Date: \(selectedDate.formatted(.dateTime.day().month().year()))")
        print("⏰ Time Slot: \(selectedTimeSlot.startTime) - \(selectedTimeSlot.endTime)")
        print("💰 Amount: €\(String(format: "%.2f", amount))")
        print("🏃‍♂️ Sport: \(lesson.sport.name)")
        
        return newBooking
    }
    
    func cancelBooking(_ booking: Booking) {
        if let index = userBookings.firstIndex(where: { $0.id == booking.id }) {
            userBookings[index].status = .cancelled
            print("❌ Booking cancelled: \(booking.id)")
        }
    }
    
    func getBookingById(_ id: String) -> Booking? {
        return userBookings.first(where: { $0.id == id })
    }
    
    func getUpcomingBookings() -> [Booking] {
        return userBookings.filter { 
            $0.lessonDate > Date() && ($0.status == .confirmed || $0.status == .pending)
        }
    }
    
    // Simulate real-time updates (in real app would come from backend)
    func simulateBookingUpdate() {
        // This could be called when receiving push notifications or websocket updates
        objectWillChange.send()
    }
}

