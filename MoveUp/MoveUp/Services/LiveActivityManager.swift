import Foundation
import ActivityKit
import SwiftUI

// MARK: - Live Activity Manager
@available(iOS 16.1, *)
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var activeActivities: [String: Activity<LessonActivityAttributes>] = [:]
    
    private init() {}
    
    // MARK: - Availability Check
    
    func areLiveActivitiesEnabled() -> Bool {
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    func requestAuthorization() {
        // Live Activities don't require explicit authorization
        // but we can check if they're enabled
        print("📱 Live Activities enabled: \(areLiveActivitiesEnabled())")
    }
    
    // MARK: - Start Live Activity
    
    func startLessonActivity(
        booking: Booking,
        lesson: Lesson,
        instructor: Instructor
    ) -> String? {
        guard areLiveActivitiesEnabled() else {
            print("❌ Live Activities are not enabled")
            return nil
        }
        
        let attributes = LessonActivityAttributes(
            lessonId: booking.id,
            lessonTitle: lesson.title,
            instructorName: instructor.userId,
            location: lesson.location.address,
            sport: lesson.sport.name
        )
        
        let initialState = LessonActivityAttributes.ContentState(
            lessonStartTime: booking.scheduledDate,
            currentTime: Date(),
            status: determineStatus(for: booking.scheduledDate),
            instructorLocation: nil
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            
            activeActivities[booking.id] = activity
            
            print("✅ Live Activity started for lesson: \(booking.id)")
            print("   Activity ID: \(activity.id)")
            
            // Schedule automatic updates
            scheduleActivityUpdates(for: booking.id, startTime: booking.scheduledDate)
            
            return activity.id
            
        } catch {
            print("❌ Error starting Live Activity: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Update Live Activity
    
    func updateLessonActivity(
        bookingId: String,
        status: LessonStatus? = nil,
        instructorLocation: InstructorLocation? = nil
    ) {
        guard let activity = activeActivities[bookingId] else {
            print("⚠️ No active activity found for booking: \(bookingId)")
            return
        }
        
        Task {
            let currentState = activity.content.state
            
            let newState = LessonActivityAttributes.ContentState(
                lessonStartTime: currentState.lessonStartTime,
                currentTime: Date(),
                status: status ?? currentState.status,
                instructorLocation: instructorLocation ?? currentState.instructorLocation
            )
            
            await activity.update(
                ActivityContent(state: newState, staleDate: nil)
            )
            
            print("✅ Live Activity updated for lesson: \(bookingId)")
        }
    }
    
    // MARK: - End Live Activity
    
    func endLessonActivity(
        bookingId: String,
        dismissalPolicy: ActivityUIDismissalPolicy = .default
    ) {
        guard let activity = activeActivities[bookingId] else {
            print("⚠️ No active activity found for booking: \(bookingId)")
            return
        }
        
        Task {
            // Final update before ending
            let finalState = LessonActivityAttributes.ContentState(
                lessonStartTime: activity.content.state.lessonStartTime,
                currentTime: Date(),
                status: .completed,
                instructorLocation: nil
            )
            
            await activity.update(ActivityContent(state: finalState, staleDate: nil))
            
            // End activity with dismissal policy
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: dismissalPolicy
            )
            
            activeActivities.removeValue(forKey: bookingId)
            
            print("✅ Live Activity ended for lesson: \(bookingId)")
        }
    }
    
    // MARK: - End All Activities
    
    func endAllActivities() {
        for (bookingId, _) in activeActivities {
            endLessonActivity(bookingId: bookingId)
        }
    }
    
    // MARK: - Helper Functions
    
    private func determineStatus(for startTime: Date) -> LessonStatus {
        let now = Date()
        let timeUntilStart = startTime.timeIntervalSince(now)
        
        if timeUntilStart < 0 {
            return .inProgress
        } else if timeUntilStart < 300 { // 5 minutes
            return .starting
        } else {
            return .upcoming
        }
    }
    
    private func scheduleActivityUpdates(for bookingId: String, startTime: Date) {
        // Update status at specific intervals
        let now = Date()
        let timeUntilStart = startTime.timeIntervalSince(now)
        
        // Update when 5 minutes before
        if timeUntilStart > 300 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (timeUntilStart - 300)) {
                self.updateLessonActivity(bookingId: bookingId, status: .starting)
            }
        }
        
        // Update when lesson starts
        if timeUntilStart > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilStart) {
                self.updateLessonActivity(bookingId: bookingId, status: .inProgress)
            }
        }
        
        // Update every minute to keep time accurate
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            guard self.activeActivities[bookingId] != nil else {
                timer.invalidate()
                return
            }
            
            self.updateLessonActivity(bookingId: bookingId)
        }
    }
}

// MARK: - SwiftUI Integration
extension View {
    @available(iOS 16.1, *)
    @ViewBuilder
    func startLiveActivityButton(
        booking: Booking,
        lesson: Lesson,
        instructor: Instructor,
        onStart: @escaping (String?) -> Void
    ) -> some View {
        Button(action: {
            let activityId = LiveActivityManager.shared.startLessonActivity(
                booking: booking,
                lesson: lesson,
                instructor: instructor
            )
            onStart(activityId)
        }) {
            HStack {
                Image(systemName: "livephoto")
                Text("Attiva Live Activity")
            }
            .font(MoveUpFont.body())
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .cornerRadius(12)
        }
        .disabled(!LiveActivityManager.shared.areLiveActivitiesEnabled())
    }
}
