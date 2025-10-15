import SwiftUI

struct BookingView: View {
    let lesson: Lesson
    let instructor: Instructor
    @Binding var selectedDate: Date
    @Binding var selectedTimeSlot: TimeSlot?
    
    @Environment(\.dismiss) private var dismiss
    @State private var showPayment = false
    @State private var notes = ""
    
    // Sample time slots
    private let availableTimeSlots: [TimeSlot] = [
        TimeSlot(id: "1", startTime: "09:00", endTime: "10:00", isAvailable: true),
        TimeSlot(id: "2", startTime: "10:30", endTime: "11:30", isAvailable: true),
        TimeSlot(id: "3", startTime: "14:00", endTime: "15:00", isAvailable: false),
        TimeSlot(id: "4", startTime: "15:30", endTime: "16:30", isAvailable: true),
        TimeSlot(id: "5", startTime: "17:00", endTime: "18:00", isAvailable: true)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: MoveUpSpacing.large) {
                    // Lesson Summary
                    VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                        Text("Riepilogo Lezione")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpPrimary)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(lesson.title)
                                    .font(MoveUpFont.body())
                                    .fontWeight(.semibold)
                                
                                Text("con \(instructor.userId)")
                                    .font(MoveUpFont.caption())
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(lesson.priceFormatted)
                                .font(MoveUpFont.subtitle())
                                .fontWeight(.bold)
                                .foregroundColor(Color.moveUpPrimary)
                        }
                        .padding()
                        .background(Color.moveUpPrimary.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                        Text("Seleziona Data")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpPrimary)
                        
                        DatePicker(
                            "Data lezione",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .background(Color.moveUpPrimary.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Time Slot Selection
                    VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                        Text("Orari Disponibili")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpPrimary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: MoveUpSpacing.small) {
                            ForEach(availableTimeSlots) { timeSlot in
                                TimeSlotCard(
                                    timeSlot: timeSlot,
                                    isSelected: selectedTimeSlot?.id == timeSlot.id
                                ) {
                                    if timeSlot.isAvailable {
                                        selectedTimeSlot = timeSlot
                                    }
                                }
                            }
                        }
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: MoveUpSpacing.medium) {
                        Text("Note aggiuntive (opzionale)")
                            .font(MoveUpFont.subtitle())
                            .foregroundColor(Color.moveUpPrimary)
                        
                        TextField("Scrivi eventuali richieste specifiche...", text: $notes, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.moveUpPrimary.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, MoveUpSpacing.large)
            }
            .navigationTitle("Prenotazione")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Continua") {
                        showPayment = true
                    }
                    .disabled(selectedTimeSlot == nil)
                }
            }
        }
        .sheet(isPresented: $showPayment) {
            PaymentView(
                lesson: lesson,
                instructor: instructor,
                selectedDate: selectedDate,
                selectedTimeSlot: selectedTimeSlot!
            )
        }
    }
}

struct TimeSlot: Identifiable {
    let id: String
    let startTime: String
    let endTime: String
    let isAvailable: Bool
    
    var displayTime: String {
        "\(startTime) - \(endTime)"
    }
}

struct TimeSlotCard: View {
    let timeSlot: TimeSlot
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(timeSlot.displayTime)
                .font(MoveUpFont.body())
                .foregroundColor(
                    timeSlot.isAvailable ? 
                        (isSelected ? .white : Color.moveUpPrimary) : 
                        .gray
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            timeSlot.isAvailable ?
                                (isSelected ? Color.moveUpPrimary : Color.moveUpPrimary.opacity(0.1)) :
                                Color.gray.opacity(0.1)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            timeSlot.isAvailable ?
                                (isSelected ? Color.moveUpPrimary : Color.moveUpPrimary.opacity(0.3)) :
                                Color.gray.opacity(0.3),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!timeSlot.isAvailable)
    }
}

struct BookingView_Previews: PreviewProvider {
    static var previews: some View {
        BookingView(
            lesson: MockDataService.shared.mockLessons.first!,
            instructor: MockDataService.shared.mockInstructors.first!,
            selectedDate: .constant(Date()),
            selectedTimeSlot: .constant(nil)
        )
    }
}