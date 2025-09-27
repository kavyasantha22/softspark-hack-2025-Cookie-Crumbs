//
//  EventStore.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import Foundation
import Combine

final class EventStore: ObservableObject {
    @Published private(set) var events: [Event] = []
    private let fileURL: URL
    private weak var userStore: UserStore?
    private weak var notificationManager: NotificationManager?

    init(fileName: String = "events.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(fileName)
        load()
        if events.isEmpty {
            seed()
            save()
        }
        // Clean up expired sparks on app start
        cleanupExpiredSparks()
    }
    
    func setUserStore(_ userStore: UserStore) {
        self.userStore = userStore
    }
    
    func setNotificationManager(_ notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }

    func add(_ event: Event) {
        events.insert(event, at: 0)
        userStore?.createSpark(event.id)
        
        // Schedule notifications for the new spark
        notificationManager?.scheduleSparkReminder(for: event, minutesBefore: 15)
        notificationManager?.scheduleSparkEndingSoon(for: event, minutesBefore: 10)
        notificationManager?.notifyNewSparkCreated(event: event)
        
        save()
    }

    func join(eventId: UUID) -> Bool {
        guard let idx = events.firstIndex(where: { $0.id == eventId }) else { return false }
        var e = events[idx]
        guard !e.isClosed else { return false }
        
        // Check if user has already joined this spark
        if userStore?.currentUser.joinedSparkIds.contains(eventId) == true {
            return false
        }
        
        // Check if user has any active spark (only one active spark allowed)
        if let activeSparkId = userStore?.currentUser.joinedSparkIds.first(where: { sparkId in
            if let activeEvent = events.first(where: { $0.id == sparkId }) {
                return !activeEvent.isEnded
            }
            return false
        }) {
            // User already has an active spark
            return false
        }
        
        let oldParticipants = e.participants
        e.participants = min(e.participants + 1, e.maxParticipants)
        events[idx] = e
        userStore?.joinSpark(eventId)
        
        // Send notifications
        notificationManager?.notifySparkJoined(event: e)
        notificationManager?.scheduleSparkReminder(for: e, minutesBefore: 15)
        notificationManager?.scheduleSparkEndingSoon(for: e, minutesBefore: 10)
        
        // Notify creator if someone else joined
        if userStore?.currentUser.createdSparkIds.contains(eventId) == false {
            notificationManager?.notifyNewParticipant(event: e, participantCount: e.participants)
        }
        
        save()
        return true
    }
    
    func leave(eventId: UUID) -> Bool {
        guard let idx = events.firstIndex(where: { $0.id == eventId }) else { return false }
        var e = events[idx]
        
        // Check if user has joined this spark
        guard userStore?.currentUser.joinedSparkIds.contains(eventId) == true else { return false }
        
        e.participants = max(e.participants - 1, 0)
        events[idx] = e
        userStore?.leaveSpark(eventId)
        
        // Cancel notifications for this spark since user left
        notificationManager?.cancelSparkNotifications(for: eventId)
        
        save()
        return true
    }

    func remove(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            events.remove(at: index)
        }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([Event].self, from: data) {
            events = decoded
        }
    }

    private func save() {
        let data = (try? JSONEncoder().encode(events)) ?? Data()
        try? data.write(to: fileURL, options: [.atomic])
    }
    
    // Clean up expired sparks and update user records
    func cleanupExpiredSparks() {
        let now = Date()
        var hasChanges = false
        
        for (index, event) in events.enumerated() {
            if event.endsAt <= now && !event.isClosed {
                // Mark event as ended by updating participant count to trigger isClosed
                var updatedEvent = event
                // Events that have passed their end time are automatically closed
                events[index] = updatedEvent
                hasChanges = true
                
                // Remove from active sparks for all users who joined
                userStore?.removeFromActiveSparks(eventId: event.id)
            }
        }
        
        if hasChanges {
            save()
        }
    }
    
    // Call this periodically to clean up expired sparks
    func refreshSparkStatuses() {
        cleanupExpiredSparks()
    }

    private func seed() {
        let now = Date()
        events = [
            Event(name: "Chess", location: "Park Pavilion", endsAt: Calendar.current.date(byAdding: .minute, value: 90, to: now)!, descriptionText: "Casual chess games.", imageURLString: nil, maxParticipants: 4, participants: 1, latitude: 37.7849, longitude: -122.4094),
            Event(name: "Football", location: "Riverside Field", endsAt: Calendar.current.date(byAdding: .minute, value: 120, to: now)!, descriptionText: "5-a-side pickup.", imageURLString: nil, maxParticipants: 10, participants: 3, latitude: 37.7849, longitude: -122.4074),
            Event(name: "Drawing", location: "Community Hall", endsAt: Calendar.current.date(byAdding: .minute, value: 60, to: now)!, descriptionText: "Sketch session.", imageURLString: nil, maxParticipants: 5, participants: 2, latitude: 37.7829, longitude: -122.4084)
        ]
    }
}


