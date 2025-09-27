//
//  NotificationSettingsView.swift
//  SparkPlay
//
//  Created by Assistant on 26/9/2025.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var userStore: UserStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var reminderEnabled = true
    @State private var endingEnabled = true
    @State private var newParticipantEnabled = true
    @State private var creationEnabled = true
    @State private var reminderMinutes = 15
    @State private var endingMinutes = 10
    
    let reminderOptions = [5, 10, 15, 30, 60]
    let endingOptions = [5, 10, 15]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notification Permission")
                            .font(.headline)
                        Text(notificationStatusText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if !notificationManager.isAuthorized {
                            Button("Enable Notifications") {
                                Task {
                                    await notificationManager.requestAuthorization()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if notificationManager.isAuthorized {
                    Section("Spark Reminders") {
                        Toggle("Spark Starting Soon", isOn: $reminderEnabled)
                        
                        if reminderEnabled {
                            HStack {
                                Text("Remind me")
                                Spacer()
                                Picker("Minutes", selection: $reminderMinutes) {
                                    ForEach(reminderOptions, id: \.self) { minutes in
                                        Text("\(minutes) min before")
                                            .tag(minutes)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                    }
                    
                    Section("Spark Activity") {
                        Toggle("Spark Ending Soon", isOn: $endingEnabled)
                        
                        if endingEnabled {
                            HStack {
                                Text("Alert me")
                                Spacer()
                                Picker("Minutes", selection: $endingMinutes) {
                                    ForEach(endingOptions, id: \.self) { minutes in
                                        Text("\(minutes) min before ending")
                                            .tag(minutes)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        
                        Toggle("New Participants Join My Sparks", isOn: $newParticipantEnabled)
                    }
                    
                    Section("My Activity") {
                        Toggle("Spark Creation Confirmation", isOn: $creationEnabled)
                    }
                    
                    Section {
                        Button("Test Notification") {
                            sendTestNotification()
                        }
                        .foregroundStyle(.blue)
                        
                        Button("Demo: Quick Spark (2 min)") {
                            createDemoSpark()
                        }
                        .foregroundStyle(.orange)
                        
                        Button("Show Pending Notifications") {
                            Task {
                                await showPendingNotifications()
                            }
                        }
                        .foregroundStyle(.purple)
                        
                        Button("Clear All Notifications") {
                            notificationManager.cancelAllNotifications()
                            notificationManager.clearBadge()
                        }
                        .foregroundStyle(.red)
                    } footer: {
                        Text("Demo features: Test sends immediate notification, Quick Spark creates a 2-minute demo spark with fast notifications.")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            loadSettings()
        }
        .onChange(of: reminderEnabled) { _, _ in saveSettings() }
        .onChange(of: endingEnabled) { _, _ in saveSettings() }
        .onChange(of: newParticipantEnabled) { _, _ in saveSettings() }
        .onChange(of: creationEnabled) { _, _ in saveSettings() }
        .onChange(of: reminderMinutes) { _, _ in saveSettings() }
        .onChange(of: endingMinutes) { _, _ in saveSettings() }
    }
    
    private var notificationStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return "Notifications are enabled. You'll receive alerts for spark activity."
        case .denied:
            return "Notifications are disabled. Enable them in Settings to get spark updates."
        case .notDetermined:
            return "Allow SparkPlay to send you notifications about your sparks."
        case .provisional:
            return "Notifications are quietly enabled."
        case .ephemeral:
            return "Temporary notification access."
        @unknown default:
            return "Notification status unknown."
        }
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification! 🧪"
        content.body = "Your notification settings are working perfectly!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "test_notification",
            content: content,
            trigger: nil // Immediate
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send test notification: \(error)")
            }
        }
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        reminderEnabled = defaults.bool(forKey: "notification_reminder_enabled") 
        endingEnabled = defaults.bool(forKey: "notification_ending_enabled")
        newParticipantEnabled = defaults.bool(forKey: "notification_participant_enabled")
        creationEnabled = defaults.bool(forKey: "notification_creation_enabled")
        reminderMinutes = defaults.object(forKey: "notification_reminder_minutes") as? Int ?? 15
        endingMinutes = defaults.object(forKey: "notification_ending_minutes") as? Int ?? 10
        
        // Default to true for first-time users
        if !defaults.bool(forKey: "notification_settings_initialized") {
            reminderEnabled = true
            endingEnabled = true
            newParticipantEnabled = true
            creationEnabled = true
            defaults.set(true, forKey: "notification_settings_initialized")
        }
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(reminderEnabled, forKey: "notification_reminder_enabled")
        defaults.set(endingEnabled, forKey: "notification_ending_enabled")
        defaults.set(newParticipantEnabled, forKey: "notification_participant_enabled")
        defaults.set(creationEnabled, forKey: "notification_creation_enabled")
        defaults.set(reminderMinutes, forKey: "notification_reminder_minutes")
        defaults.set(endingMinutes, forKey: "notification_ending_minutes")
    }
    
    private func createDemoSpark() {
        let now = Date()
        let endTime = Calendar.current.date(byAdding: .minute, value: 2, to: now) ?? now
        
        let demoEvent = Event(
            name: "Demo Spark ⚡",
            location: "Demo Location",
            endsAt: endTime,
            descriptionText: "Quick 2-minute demo spark to test notifications",
            imageURLString: nil,
            maxParticipants: 5,
            participants: 1,
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        eventStore.add(demoEvent)
        
        // Schedule fast notifications for demo (30 seconds and 1 minute before end)
        notificationManager.scheduleSparkReminder(for: demoEvent, minutesBefore: 1)
        notificationManager.scheduleSparkEndingSoon(for: demoEvent, minutesBefore: 1)
    }
    
    private func showPendingNotifications() async {
        let pending = await notificationManager.getPendingNotifications()
        print("📅 Pending Notifications (\(pending.count)):")
        for request in pending {
            print("  • \(request.content.title): \(request.content.body)")
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                print("    Scheduled for: \(trigger.nextTriggerDate() ?? Date())")
            }
        }
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(NotificationManager())
        .environmentObject(EventStore())
        .environmentObject(UserStore())
}
