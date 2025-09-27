//
//  NotificationManager.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import Foundation
import UserNotifications
import SwiftUI
import Combine

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Spark Notifications
    
    func scheduleSparkReminder(for event: Event, minutesBefore: Int = 15) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Spark Starting Soon! ⚡"
        content.body = "\(event.name) starts in \(minutesBefore) minutes at \(event.location)"
        content.sound = .default
        content.badge = 1
        
        // Add custom data
        content.userInfo = [
            "sparkId": event.id.uuidString,
            "type": "reminder"
        ]
        
        // Schedule for 15 minutes before start
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: event.endsAt)
        
        // Only schedule if the trigger date is in the future
        guard let triggerDate = triggerDate, triggerDate > Date() else { return }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "spark_reminder_\(event.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error)")
            }
        }
    }
    
    func scheduleSparkEndingSoon(for event: Event, minutesBefore: Int = 10) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Spark Ending Soon! 🔥"
        content.body = "\(event.name) ends in \(minutesBefore) minutes. Don't miss out!"
        content.sound = .default
        
        content.userInfo = [
            "sparkId": event.id.uuidString,
            "type": "ending_soon"
        ]
        
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: event.endsAt)
        
        guard let triggerDate = triggerDate, triggerDate > Date() else { return }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "spark_ending_\(event.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule ending notification: \(error)")
            }
        }
    }
    
    func notifyNewSparkCreated(event: Event) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Spark Created! ✨"
        content.body = "You created \(event.name) at \(event.location). Good luck!"
        content.sound = .default
        
        content.userInfo = [
            "sparkId": event.id.uuidString,
            "type": "created"
        ]
        
        // Immediate notification
        let request = UNNotificationRequest(
            identifier: "spark_created_\(event.id.uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send creation notification: \(error)")
            }
        }
    }
    
    func notifySparkJoined(event: Event) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Spark Joined! 🎉"
        content.body = "You joined \(event.name)! See you at \(event.location)."
        content.sound = .default
        
        content.userInfo = [
            "sparkId": event.id.uuidString,
            "type": "joined"
        ]
        
        let request = UNNotificationRequest(
            identifier: "spark_joined_\(event.id.uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send join notification: \(error)")
            }
        }
    }
    
    func notifyNewParticipant(event: Event, participantCount: Int) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Someone Joined Your Spark! 👥"
        content.body = "\(event.name) now has \(participantCount) participants"
        content.sound = .default
        
        content.userInfo = [
            "sparkId": event.id.uuidString,
            "type": "new_participant"
        ]
        
        let request = UNNotificationRequest(
            identifier: "new_participant_\(event.id.uuidString)_\(participantCount)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send participant notification: \(error)")
            }
        }
    }
    
    // MARK: - Management
    
    func cancelSparkNotifications(for eventId: UUID) {
        let identifiers = [
            "spark_reminder_\(eventId.uuidString)",
            "spark_ending_\(eventId.uuidString)"
        ]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: - Badge Management
    
    func updateBadgeCount() {
        Task {
            let pending = await getPendingNotifications()
            await MainActor.run {
                UNUserNotificationCenter.current().setBadgeCount(pending.count)
            }
        }
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let sparkIdString = userInfo["sparkId"] as? String,
           let sparkId = UUID(uuidString: sparkIdString) {
            
            // Post notification to handle deep linking to spark
            NotificationCenter.default.post(
                name: .openSpark,
                object: nil,
                userInfo: ["sparkId": sparkId]
            )
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openSpark = Notification.Name("openSpark")
}
