//
//  NotificationsView.swift
//  MoveUp
//
//  Created by MoveUp Team on 14/10/2025.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notifications: [AppNotification] = AppNotification.sampleNotifications
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.moveUpBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(notifications) { notification in
                            NotificationCard(notification: notification) {
                                markAsRead(notification)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Notifiche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Segna tutte") {
                        markAllAsRead()
                    }
                    .font(.caption)
                    .foregroundColor(.moveUpPrimary)
                }
            }
        }
    }
    
    private func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    private func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}

struct NotificationCard: View {
    let notification: AppNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconName)
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.moveUpTextPrimary)
                    
                    Text(notification.message)
                        .font(.system(size: 14))
                        .foregroundColor(.moveUpTextSecondary)
                        .lineLimit(2)
                    
                    Text(timeAgo(notification.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.moveUpTextSecondary)
                }
                
                Spacer()
                
                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(Color.moveUpPrimary)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            .background(notification.isRead ? Color.moveUpCardBackground : Color.moveUpPrimary.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        switch notification.type {
        case .booking: return "calendar"
        case .payment: return "creditcard"
        case .review: return "star.fill"
        case .promotion: return "gift.fill"
        case .system: return "bell.fill"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .booking: return Color.moveUpSecondary
        case .payment: return Color.moveUpAccent2
        case .review: return Color.moveUpGamification
        case .promotion: return Color.moveUpAccent1
        case .system: return Color.moveUpPrimary
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: Date())
        
        if let day = components.day, day > 0 {
            return "\(day)g fa"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)h fa"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)m fa"
        }
        return "Ora"
    }
}

// MARK: - Sample Data
extension AppNotification {
    static let sampleNotifications: [AppNotification] = [
        AppNotification(
            id: "1",
            userId: "user1",
            title: "Lezione confermata!",
            message: "La tua lezione di Tennis con Mario Rossi è stata confermata per domani alle 10:00",
            type: .booking,
            isRead: false,
            actionURL: nil,
            createdAt: Date().addingTimeInterval(-3600) // 1h fa
        ),
        AppNotification(
            id: "2",
            userId: "user1",
            title: "Pagamento ricevuto",
            message: "Il pagamento di €45.00 è stato elaborato con successo",
            type: .payment,
            isRead: false,
            actionURL: nil,
            createdAt: Date().addingTimeInterval(-7200) // 2h fa
        ),
        AppNotification(
            id: "3",
            userId: "user1",
            title: "Nuova recensione",
            message: "Mario Rossi ha lasciato una recensione per la tua ultima lezione!",
            type: .review,
            isRead: true,
            actionURL: nil,
            createdAt: Date().addingTimeInterval(-86400) // 1 giorno fa
        ),
        AppNotification(
            id: "4",
            userId: "user1",
            title: "🎁 Promozione speciale!",
            message: "Prima lezione GRATIS con i nuovi istruttori. Approfitta ora!",
            type: .promotion,
            isRead: true,
            actionURL: nil,
            createdAt: Date().addingTimeInterval(-172800) // 2 giorni fa
        ),
        AppNotification(
            id: "5",
            userId: "user1",
            title: "Guadagna 50 punti!",
            message: "Invita un amico e ricevi 50 punti bonus alla sua prima prenotazione",
            type: .system,
            isRead: true,
            actionURL: nil,
            createdAt: Date().addingTimeInterval(-259200) // 3 giorni fa
        )
    ]
}
