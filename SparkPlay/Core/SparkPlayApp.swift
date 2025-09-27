//
//  SparkPlayApp.swift
//  SparkPlay
//
//  Created by Putu Kavya Santha Guna on 26/9/2025.
//

import SwiftUI
import UserNotifications

@main
struct SparkPlayApp: App {
    @StateObject private var eventStore = EventStore()
    @StateObject private var userStore = UserStore()
    @StateObject private var notificationManager = NotificationManager()
    
    private let notificationDelegate = NotificationDelegate()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(eventStore)
                .environmentObject(userStore)
                .environmentObject(notificationManager)
                .onAppear {
                    eventStore.setUserStore(userStore)
                    eventStore.setNotificationManager(notificationManager)
                    setupNotifications()
                }
                .onReceive(NotificationCenter.default.publisher(for: .openSpark)) { notification in
                    if let sparkId = notification.userInfo?["sparkId"] as? UUID {
                        // Handle deep linking to spark - could implement navigation here
                        print("Open spark: \(sparkId)")
                    }
                }
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        Task {
            await notificationManager.requestAuthorization()
        }
    }
}
