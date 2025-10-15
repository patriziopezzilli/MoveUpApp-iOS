//
//  CalendarManager.swift
//  MoveUp
//
//  Created by MoveUp on 14/10/2025.
//

import Foundation
import Combine
import EventKit
import SwiftUI

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorizationStatus()
    }
    
    // Controlla lo stato di autorizzazione
    func checkAuthorizationStatus() {
        if #available(iOS 17.0, *) {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        } else {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }
    }
    
    // Richiedi permesso per accedere al calendario
    func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                self.authorizationStatus = granted ? .fullAccess : .denied
            }
            return granted
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    Task { @MainActor in
                        self.authorizationStatus = granted ? .authorized : .denied
                    }
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }
    
    // Crea un evento nel calendario
    func createEvent(
        title: String,
        startDate: Date,
        endDate: Date,
        location: String? = nil,
        notes: String? = nil,
        calendar: EKCalendar? = nil
    ) throws -> String {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.notes = notes
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        
        try eventStore.save(event, span: .thisEvent)
        return event.eventIdentifier
    }
    
    // Aggiorna un evento esistente
    func updateEvent(
        eventId: String,
        title: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        location: String? = nil,
        notes: String? = nil
    ) throws {
        guard let event = eventStore.event(withIdentifier: eventId) else {
            throw CalendarError.eventNotFound
        }
        
        if let title = title { event.title = title }
        if let startDate = startDate { event.startDate = startDate }
        if let endDate = endDate { event.endDate = endDate }
        if let location = location { event.location = location }
        if let notes = notes { event.notes = notes }
        
        try eventStore.save(event, span: .thisEvent)
    }
    
    // Elimina un evento
    func deleteEvent(eventId: String) throws {
        guard let event = eventStore.event(withIdentifier: eventId) else {
            throw CalendarError.eventNotFound
        }
        try eventStore.remove(event, span: .thisEvent)
    }
    
    // Ottieni tutti gli eventi in un intervallo di date
    func fetchEvents(startDate: Date, endDate: Date) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        return eventStore.events(matching: predicate)
    }
    
    // Ottieni i calendari disponibili
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }
}

enum CalendarError: LocalizedError {
    case accessDenied
    case eventNotFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Accesso al calendario negato. Vai nelle Impostazioni per abilitarlo."
        case .eventNotFound:
            return "Evento non trovato nel calendario."
        case .saveFailed:
            return "Impossibile salvare l'evento nel calendario."
        }
    }
}
