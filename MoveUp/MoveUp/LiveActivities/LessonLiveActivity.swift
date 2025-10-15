import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Lesson Activity Attributes
struct LessonActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var lessonStartTime: Date
        var currentTime: Date
        var status: LessonStatus
        var instructorLocation: InstructorLocation?
    }
    
    // Static data (doesn't change during activity)
    var lessonId: String
    var lessonTitle: String
    var instructorName: String
    var location: String
    var sport: String
}

// MARK: - Lesson Status
enum LessonStatus: String, Codable, Hashable {
    case upcoming = "in_arrivo"
    case starting = "sta_iniziando"
    case inProgress = "in_corso"
    case completed = "completata"
    
    var displayText: String {
        switch self {
        case .upcoming: return "Tra poco"
        case .starting: return "Inizia ora!"
        case .inProgress: return "In corso"
        case .completed: return "Completata"
        }
    }
    
    var color: Color {
        switch self {
        case .upcoming: return .blue
        case .starting: return .orange
        case .inProgress: return .green
        case .completed: return .gray
        }
    }
}

// MARK: - Instructor Location
struct InstructorLocation: Codable, Hashable {
    var latitude: Double
    var longitude: Double
    var distance: Double? // Distance in meters
}

// MARK: - Live Activity Widget
@available(iOS 16.1, *)
struct LessonLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LessonActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            LessonLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: getSportIcon(context.attributes.sport))
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.sport)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(context.attributes.lessonTitle)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.state.status.displayText)
                            .font(.caption2)
                            .foregroundColor(context.state.status.color)
                        
                        Text(timeUntilLesson(context.state.lessonStartTime, current: context.state.currentTime))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .monospacedDigit()
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    // Empty - we use leading and trailing
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 12) {
                        // Instructor info
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                            Text(context.attributes.instructorName)
                                .font(.caption)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                            Text(context.attributes.location)
                                .font(.caption)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Link(destination: URL(string: "moveup://contact")!) {
                                Label("Contatta", systemImage: "phone.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(8)
                            }
                            
                            Link(destination: URL(string: "maps://?q=\(context.attributes.location)")!) {
                                Label("Naviga", systemImage: "map.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.green.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                // Compact Leading (Dynamic Island)
                Image(systemName: getSportIcon(context.attributes.sport))
                    .foregroundColor(.white)
            } compactTrailing: {
                // Compact Trailing (Dynamic Island)
                Text(timeUntilLessonShort(context.state.lessonStartTime, current: context.state.currentTime))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .monospacedDigit()
            } minimal: {
                // Minimal (when multiple activities)
                Image(systemName: getSportIcon(context.attributes.sport))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getSportIcon(_ sport: String) -> String {
        switch sport.lowercased() {
        case "tennis": return "tennisball.fill"
        case "calcio", "football": return "football.fill"
        case "basket", "basketball": return "basketball.fill"
        case "corsa", "running": return "figure.run"
        case "yoga": return "figure.yoga"
        case "nuoto", "swimming": return "figure.pool.swim"
        default: return "figure.walk"
        }
    }
    
    private func timeUntilLesson(_ startTime: Date, current: Date) -> String {
        let interval = startTime.timeIntervalSince(current)
        
        if interval < 0 {
            return "Iniziata"
        }
        
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes) min"
        }
    }
    
    private func timeUntilLessonShort(_ startTime: Date, current: Date) -> String {
        let interval = startTime.timeIntervalSince(current)
        
        if interval < 0 {
            return "•"
        }
        
        let minutes = Int(interval / 60)
        
        if minutes > 60 {
            return "\(minutes / 60)h"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Live Activity Lock Screen View
struct LessonLiveActivityView: View {
    let context: ActivityViewContext<LessonActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: getSportIcon(context.attributes.sport))
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.lessonTitle)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("con \(context.attributes.instructorName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(context.state.status.displayText)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(context.state.status.color)
                    
                    Text(timeUntilLesson())
                        .font(.title3)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }
            
            // Location
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.secondary)
                Text(context.attributes.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // Progress bar
            if context.state.status == .upcoming || context.state.status == .starting {
                ProgressView(value: progressValue())
                    .tint(.blue)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
    
    private func getSportIcon(_ sport: String) -> String {
        switch sport.lowercased() {
        case "tennis": return "tennisball.fill"
        case "calcio", "football": return "football.fill"
        case "basket", "basketball": return "basketball.fill"
        case "corsa", "running": return "figure.run"
        case "yoga": return "figure.yoga"
        case "nuoto", "swimming": return "figure.pool.swim"
        default: return "figure.walk"
        }
    }
    
    private func timeUntilLesson() -> String {
        let interval = context.state.lessonStartTime.timeIntervalSince(context.state.currentTime)
        
        if interval < 0 {
            return "Iniziata"
        }
        
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes) minuti"
        }
    }
    
    private func progressValue() -> Double {
        // Progress from now to lesson start (1 hour window)
        let totalDuration: TimeInterval = 3600 // 1 hour
        let elapsed = Date().timeIntervalSince(context.state.lessonStartTime.addingTimeInterval(-totalDuration))
        return min(max(elapsed / totalDuration, 0), 1)
    }
}

// MARK: - Usage Example in App
/*
 
 // Start Live Activity when booking is confirmed
 func startLessonActivity(booking: Booking, lesson: Lesson, instructor: Instructor) {
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
         status: .upcoming,
         instructorLocation: nil
     )
     
     do {
         let activity = try Activity.request(
             attributes: attributes,
             contentState: initialState,
             pushType: nil
         )
         print("✅ Live Activity started: \(activity.id)")
     } catch {
         print("❌ Error starting Live Activity: \(error)")
     }
 }
 
 // Update Live Activity
 func updateLessonActivity(activityId: String, newStatus: LessonStatus) {
     Task {
         let updatedState = LessonActivityAttributes.ContentState(
             lessonStartTime: // keep same
             currentTime: Date(),
             status: newStatus,
             instructorLocation: nil
         )
         
         await activity.update(using: updatedState)
     }
 }
 
 // End Live Activity
 func endLessonActivity(activityId: String) {
     Task {
         await activity.end(dismissalPolicy: .after(.now + 3600)) // 1 hour
     }
 }
 
 */
